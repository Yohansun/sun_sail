# -*- encoding : utf-8 -*-

class TaobaoPurchaseOrderPuller
  class << self
    def create(start_time = nil, end_time = nil)
      end_time ||= Time.now
      start_time ||= end_time - 7.days

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
          next if TaobaoPurchaseOrder.where(tid: trade['fenxiao_id']).exists?
          trade.delete 'id'
          sub_orders = trade.delete('sub_purchase_orders')
          purchase_order = TaobaoPurchaseOrder.new(trade)
          sub_orders = sub_orders['sub_purchase_order']
          sub_orders.each do |sub_order|
            sub_order.delete 'id'
            sub_purchase_order = purchase_order.taobao_sub_purchase_orders.build(sub_order)
          end
          purchase_order.save
          
          # 分流 或 拆分订单
          purchase_order.dispatch! unless TradeSplitter.new(purchase_order).split!
        end
      end
    end

    def update(start_time = nil, end_time = nil)
      total_pages = nil
      i = 0

      end_time ||= Time.now
      start_time ||= end_time - 7.days

      begin
        response = TaobaoFu.get(method: 'taobao.fenxiao.orders.get',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: i, page_size: 50)

        break unless response['fenxiao_orders_get_response']
        total_results = response['fenxiao_orders_get_response']['total_results']
        total_pages ||= total_results / 50
        trades = response['fenxiao_orders_get_response']['purchase_orders']['purchase_order']
        trades.each do |trade|
          TaobaoPurchaseOrder.where(tid: trade['fenxiao_id']).each do |local_trade|
            next if trade['status'] == local_trade.status || (trade['status'] == "WAIT_SELLER_SEND_GOODS" && local_trade.delivered_at.present?)
            trade.delete 'id'
            sub_orders = trade.delete('sub_purchase_orders')
            local_trade.update_attributes trade
            local_sub_orders = local_trade.taobao_sub_purchase_orders
            sub_orders['sub_purchase_order'].each do |sub_order|
              sub_order.delete 'id'
              local_sub_order_array = local_sub_orders.select {|o| o.item_id == sub_order['item_id']}
              local_sub_order = local_sub_order_array.first
              next if (local_sub_order.blank? || sub_order['status'] == local_sub_order.status)
              local_sub_order.update_attributes sub_order
            end

            # 分流 
            local_trade.dispatch!

            # 拆分订单
            # TradeSplitter.new(local_trade).split!
          end
        end

        i += 1
      end until i > total_pages
    end
  end
end