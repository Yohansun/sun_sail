# encoding : utf-8 -*-
class TaobaoTradePuller
  class << self
    def create(start_time = nil, end_time = nil, trade_source_id = nil)
      total_pages = nil
      page_no = 0

      if start_time.blank?
        latest_created_order = TaobaoTrade.only("created").order("created", "DESC").limit(1).first
        start_time = latest_created_order.created - 1.hour
      end

      if end_time.blank?
        end_time = Time.now
      end

      if trade_source_id.blank?
        trade_source_id = TradeSetting.default_taobao_trade_source_id
      end

      begin
        response = TaobaoQuery.get({
          method: 'taobao.trades.sold.get',
          fields: 'has_buyer_message, total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 40}, trade_source_id
          )

        p "starting create_orders: since #{start_time}"

        unless response['trades_sold_get_response']
          p response
          break
        end

        total_results = response['trades_sold_get_response']['total_results']
        total_results = total_results.to_i
        total_pages ||= total_results / 40
        next if total_results < 1
        trades = response['trades_sold_get_response']['trades']['trade']
        unless trades.is_a?(Array)
          trades = [] << trades
        end
        next if trades.blank?

        trades.each do |trade|

          next if ($redis.sismember('TaobaoTradeTids',trade['tid']) || TaobaoTrade.where(tid: trade['tid']).exists?)
          orders = trade.delete('orders')
          trade = TaobaoTrade.new(trade)

          trade.trade_source_id = trade_source_id

          order = orders['order']

          unless order.is_a?(Array)
            order = [] << order
          end
          order.each do |o|
            taobao_order = trade.taobao_orders.build(o)
          end

          trade.operation_logs.build(operated_at: Time.now, operation: '从淘宝抓取订单')

          trade.save

          p "create trade #{trade['tid']}"

          $redis.sadd('TaobaoTradeTids',trade['tid'])

          if trade.status == 'WAIT_SELLER_SEND_GOODS'
            if TradeSetting.company == 'dulux'
              DelayAutoDispatch.perform_in(TradeSetting.delay_time || 1.hours, trade.id)
            else
              unless TradeSplitter.new(trade).split!
                trade.auto_dispatch!
              end
            end
          end

          TradeTaobaoMemoFetcher.perform_async(trade.tid) if trade.has_buyer_message
        end

        page_no += 1
      end until(page_no > total_pages || total_pages == 0)
    end

    def update(start_time = nil, end_time = nil, trade_source_id = nil)
      if start_time.blank?
        latest_created_order = TaobaoTrade.only("modified").order("modified", "DESC").limit(1).first
        start_time = latest_created_order.modified - 4.hour
      end

      if end_time.blank?
        end_time = start_time + 1.day
      end

      if trade_source_id.blank?
        trade_source_id = TradeSetting.default_taobao_trade_source_id
      end

      has_next = true
      page_no = 1
      while has_next
        has_next = false
        Rails.logger.info "upate_orders: fetching page #{page_no}"
        puts "upate_orders: fetching page #{page_no}"

        response = TaobaoQuery.get({:method => 'taobao.trades.sold.increment.get',
          :fields => 'total_fee, tid, status, adjust_fee, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, title, type, point_fee, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          :start_modified => start_time.strftime("%Y-%m-%d %H:%M:%S"),
          :end_modified => end_time.strftime("%Y-%m-%d %H:%M:%S"),
          :page_no => page_no,
          :page_size => 40,
          :use_has_next => true}, trade_source_id
          )

        page_no += 1
        has_next = response['trades_sold_increment_get_response']['has_next']
        next unless response['trades_sold_increment_get_response']['trades']

        trades = response['trades_sold_increment_get_response']['trades']['trade']
        unless trades.is_a?(Array)
          trades = [] << trades
        end
        next if trades.blank?

        trades.each do |trade|
          TaobaoTrade.where(tid: trade['tid']).each do |local_trade|
            next unless updatable?(local_trade, trade['status'])
            orders = trade.delete('orders')
            trade['trade_source_id'] = trade_source_id
            local_trade.update_attributes(trade)

            trade.operation_logs.build(operated_at: Time.now, operation: '从淘宝更新订单')
            trade.save
            if trade.status == 'WAIT_SELLER_SEND_GOODS'
              if TradeSetting.company == 'dulux'
                DelayAutoDispatch.perform_in(TradeSetting.delay_time || 1.hours, local_trade.id)
              else
                local_trade.auto_dispatch!
              end
            end

            p "update trade #{trade['tid']}"
          end
        end
      end
    end

    def updatable?(local_trade, remote_status)
      remote_status != local_trade.status && (remote_status != "WAIT_SELLER_SEND_GOODS" && local_trade.delivered_at.blank?)
    end
  end
end
