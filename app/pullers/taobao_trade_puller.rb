# encoding : utf-8 -*- 
class TaobaoTradePuller
  class << self
    def create(start_time = nil, end_time = nil, trade_source_id = nil)
      total_pages = nil
      page_no = 0

      end_time ||= Time.now
      start_time ||= end_time - 1.days

      TaobaoFu.select_source(trade_source_id)

      begin
        response = TaobaoFu.get(method: 'taobao.trades.sold.get',
          fields: 'has_buyer_message, total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 50
        )

        total_results = response['trades_sold_get_response']['total_results']
        total_pages ||= total_results / 50

        trades = response['trades_sold_get_response']['trades']['trade']
        next if trades.blank?

        trades.each do |trade|
          next if TaobaoTrade.where(tid: trade['tid']).exists?
          orders = trade.delete('orders')
          trade = TaobaoTrade.new(trade)
          trade.trade_source_id = trade_source_id

          orders['order'].each do |order|
            order = trade.taobao_orders.build(order)
          end

          trade.save

          TradeTaobaoMemoFetcher.perform_async(trade.id) if trade.has_buyer_message

          trade.dispatch! unless TradeSplitter.new(local_trade).split!
        end

        page_no += 1
      end until page_no > total_pages
    end

    def update(start_time = nil, end_time = nil, trade_source_id = nil)
      total_pages = nil
      page_no = 0

      end_time ||= Time.now
      start_time ||= end_time - 1.days

      TaobaoFu.select_source(trade_source_id)

      begin
        response = TaobaoFu.get(method: 'taobao.trades.sold.get',
          fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 50
        )

        total_results = response['trades_sold_get_response']['total_results']
        total_pages ||= total_results / 50

        trades = response['trades_sold_get_response']['trades']['trade']
        next if trades.blank?

        trades.each do |trade|
          TaobaoTrade.where(tid: trade['tid']).each do |local_trade|
            next unless updatable?(local_trade, trade['status'])
            orders = trade.delete('orders')

            trade['trade_source_id'] = trade_source_id
            local_trade.update_attribute(trade)

            # orders['order'].each do |order|
            #   local_sub_order_array = local_sub_orders.select {|o| o.item_id == sub_order['item_id']}
            #   local_sub_order = local_sub_order_array.first
            #   next if (local_sub_order.blank? || sub_order['status'] == local_sub_order.status)
            #   local_sub_order.update_attributes sub_order
            # end

            local_trade.dispatch!
          end 
        end

        page_no += 1
      end until page_no > total_pages
    end
  end

  def updatable?(local_trade, remote_status)
    remote_status == local_trade.status || (remote_status == "WAIT_SELLER_SEND_GOODS" && local_trade.delivered_at.present?)
  end
end