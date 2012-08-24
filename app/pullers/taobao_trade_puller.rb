

class TaobaoTradePuller
  class << self
    def create(start_time = nil, end_time = nil, trade_source_id = nil)
      if trade_source_id
        source = TradeSource.find(trade_source_id)
        settings = {}
        settings['app_key'] = source.app_key
        settings['secret_key'] = source.secret_key
        settings['session'] = source.session
        TaobaoFu.settings = settings
      end

      if start_time.blank?
        start_time = Time.now - 1.days
      end

      end_time = start_time + 1.days unless end_time

      response = TaobaoFu.get(method: 'taobao.trades.sold.get',
        fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
        start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
        end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        page_no: 0, page_size: 1)

      p response

      total_results = response['trades_sold_get_response']['total_results']#['total_results']#['trades']['trade']#['trades']
      total_pages = total_results / 50

      p total_results
      p total_pages

      (0..total_pages).each do |page|
        response = TaobaoFu.get(method: 'taobao.trades.sold.get',
        fields: 'total_fee, created, tid, status, post_fee, receiver_name, pay_time, receiver_state, receiver_city, receiver_district, receiver_address, receiver_zip, receiver_mobile, receiver_phone, buyer_nick, tile, type, point_fee, is_lgtype, is_brand_sale, is_force_wlb, modified, alipay_id, alipay_no, alipay_url, shipping_type, buyer_obtain_point_fee, cod_fee, cod_status, commission_fee, seller_nick, consign_time, received_payment, payment, timeout_action_time, has_buyer_message, real_point_fee, orders',
        start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
        end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        page_no: page,
        page_size: 50)

        trades = response['trades_sold_get_response']['trades']['trade']
        trades.each do |t|
          next if TaobaoTrade.where(tid: t['tid']).exists?
          orders = t.delete('orders')
          trade = TaobaoTrade.new(t)
          trade.trade_source_id = trade_source_id
          orders = orders['order']
          orders.each do |order|
            order = trade.taobao_orders.build(order)
          end
          trade.save

        end
      end
    end


    def update

    end
  end
end