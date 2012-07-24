class TaobaoPurchaseOrderPuller
  class << self
    def create(start_time = nil, end_time = nil)
      if start_time.blank?
        start_time = Time.now - 7.days
      end

      end_time = start_time + 7.days unless end_time

      response = TaobaoFu.get(method: 'taobao.fenxiao.orders.get',
        start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
        end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        page_no: 0, page_size: 1)

      total_results = response['fenxiao_orders_get_response']['total_results']
      total_pages = total_results / 50

      (0..total_pages).each do |page|
        response = TaobaoFu.get(method: 'taobao.fenxiao.orders.get',
        start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
        end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        page_no: page, page_size: 50)

        trades = response['fenxiao_orders_get_response']['purchase_orders']['purchase_order']
        trades.each do |trade|
          next if TaobaoPurchaseOrder.where(fenxiao_id: trade['fenxiao_id']).exists?
          trade.delete 'id'
          sub_orders = trade.delete('sub_purchase_orders')
          purchase_order = TaobaoPurchaseOrder.new(trade)
          sub_orders = sub_orders['sub_purchase_order']
          sub_orders.each do |sub_order|
            sub_order.delete 'id'
            sub_purchase_order = purchase_order.taobao_sub_purchase_orders.build(sub_order)
          end
          purchase_order.save
        end
      end
    end

    def update

    end
  end
end