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
      
      begin      
        response = TaobaoQuery.get({
          method: 'taobao.trades.sold.get',
          fields: 'has_buyer_message, total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 50}, trade_source_id 
        )
        
        p "starting create_orders: since #{start_time}"
        
        break unless response['trades_sold_get_response']
        
        total_results = response['trades_sold_get_response']['total_results']
        total_results = total_results.to_i
        total_pages ||= total_results / 50
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

          trade.save
          
          p "create trade #{trade['tid']}"

          $redis.sadd('TaobaoTradeTids',trade['tid'])

          unless TradeSplitter.new(trade).split!
            if TradeSetting.company == 'dulux'
              DelayAutoDispatch.perform_in(TradeSetting.delay_time || 1.hours, trade.id)
            else
              trade.auto_dispatch!
            end
          end

           TradeTaobaoMemoFetcher.perform_async(trade.tid) if trade.has_buyer_message
        end

        page_no += 1
      end until(page_no > total_pages || total_pages == 0)
    end
    
    def update(start_time = nil, end_time = nil, trade_source_id = nil)
      total_pages = nil
      page_no = 0

      if start_time.blank?
        latest_created_order = TaobaoTrade.only("modified").order("modified", "DESC").limit(1).first
        start_time = latest_created_order.modified - 4.hour
      end
      
      if end_time.blank?
        end_time = start_time + 1.day
      end
      
      begin 
        response = TaobaoQuery.get({
          method: 'taobao.trades.sold.get',
          fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 50}, trade_source_id  
        )
        
        p "starting upate_orders: since #{start_time}"
        
        break unless response['trades_sold_get_response']
                 
        total_results = response['trades_sold_get_response']['total_results']
        total_results = total_results.to_i
        total_pages ||= total_results / 50
        next if total_results < 1 
        trades = response['trades_sold_get_response']['trades']['trade']
        unless trades.is_a?(Array)
          trades = [] << trades
        end  
        next if trades.blank?

        trades.each do |trade|
          TaobaoTrade.where(tid: trade['tid']).each do |local_trade|
            next if unupdatable?(local_trade, trade['status'])
            orders = trade.delete('orders')
            trade['trade_source_id'] = trade_source_id
            local_trade.update_attributes(trade)

            if TradeSetting.company == 'dulux'
              DelayAutoDispatch.perform_in(TradeSetting.delay_time || 1.hours, local_trade.id)
            else
              local_trade.auto_dispatch!
            end
            p "update trade #{trade['tid']}"
          end 
        end

        page_no += 1
      end until(page_no > total_pages || total_pages == 0)
    end

    def unupdatable?(local_trade, remote_status)
      remote_status == local_trade.status || (remote_status == "WAIT_SELLER_SEND_GOODS" && local_trade.delivered_at.present?)
    end
  end
end