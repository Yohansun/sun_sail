class JingdongTradePuller
  class << self
    def create(start_time = nil, end_time = nil)
      if start_time.blank?
        start_time = Time.now - 7.days
      end

      end_time = start_time + 7.days unless end_time

      order_states = 'WAIT_SELLER_DELIVERY,WAIT_SELLER_STOCK_OUT,WAIT_GOODS_RECEIVE_CONFIRM,FINISHED_L,TRADE_CANCELED'

      response = JingdongFu.get(method: '360buy.order.search',
        order_state: order_states,
        start_date: start_time.strftime("%Y-%m-%d %H:%M:%S"),
        end_date: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        page: 1,
        page_size: 1)

      p response

      total_results = response['order_search_response']['order_search']['order_total']
      total_pages = (total_results / 10 ) + 1

      p total_results
      p total_pages

      (1..total_pages).each do |page|

        response = JingdongFu.get(method: '360buy.order.search',
          order_state: order_states,
          start_date: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          end_date: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page: page,
          page_size: 10)

        trades = response['order_search_response']['order_search']['order_info_list']
        trades.each do |t|
          next if JingdongTrade.where(tid: t['order_id']).exists?
          orders = t.delete('item_info_list')
          trade = JingdongTrade.new(t)
          orders.each do |order|
            order = trade.jingdong_orders.build(order)
          end
          trade.save
        end
      end
    end


    def update

    end
  end
end
