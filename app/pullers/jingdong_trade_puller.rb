class JingdongTradePuller
  class << self
    def create(start_time = nil, end_time = nil)
      if start_time.blank?
        start_time = Time.now - 1.days
      end

      end_time = start_time + 1.days unless end_time

      response = JingdongFu.get(method: '360buy.order.search', order_state:'WAIT_SELLER_DELIVERY,WAIT_SELLER_STOCK_OUT', page:1, page_size: 10)
      # get(method: '360buy.order.search',
      # start_date: start_time.strftime("%Y-%m-%d %H:%M:%S"),
      # end_date: end_time.strftime("%Y-%m-%d %H:%M:%S"),
      # page_no: 1,
      # page_size: 10)


      p response

      total_results = response['order_search_response']['order_search']['order_total']#['total_results']#['trades']['trade']#['trades']
      total_pages = (total_results / 10 ) + 1

      p total_results
      p total_pages

      (1..total_pages).each do |page|
        response = JingdongFu.get(method: '360buy.order.search', order_state:'WAIT_SELLER_DELIVERY,WAIT_SELLER_STOCK_OUT', page: page, page_size: 10)
        # get(method: '360buy.order.search',
        # start_date: start_time.strftime("%Y-%m-%d %H:%M:%S"),
        # end_date: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        # page_no: page,
        # page_size: 10)

        trades = response['order_search_response']['order_search']['order_info_list']#['item_info_list']
        trades.each do |t|
          next if JingdongTrade.where(tid: t['order_id']).exists?
          orders = t.delete('item_info_list')
          trade = JingdongTrade.new(t)
          # orders = orders['item_info_list']
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
