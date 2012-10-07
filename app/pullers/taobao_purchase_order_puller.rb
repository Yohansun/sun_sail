# -*- encoding : utf-8 -*-

class TaobaoPurchaseOrderPuller
  class << self
    def create(start_time = nil, end_time = nil)     
      total_pages = nil
      page_no = 0
      
      end_time ||= Time.now
      start_time ||= end_time - 1.days

      begin 
      response = TaobaoQuery.get({
        method: 'taobao.fenxiao.orders.get',
        start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
        end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
        page_no: page_no, page_size: 50}, nil
      )
      
      break unless response['fenxiao_orders_get_response']
      
        total_results = response['fenxiao_orders_get_response']['total_results']
        total_results = total_results.to_i
        total_pages = total_results / 50
        next if total_results < 1 

        trades = response['fenxiao_orders_get_response']['purchase_orders']['purchase_order']
        unless trades.is_a?(Array)
          trades = [] << trades
        end
        next if trades.blank?  
            
        trades.each do |trade|
          next if ($redis.sismember('TaobaoPurchaseOrderTids', trade['fenxiao_id']) || TaobaoPurchaseOrder.where(tid: trade['fenxiao_id']).exists?)
          trade.delete 'id'
          sub_orders = trade.delete('sub_purchase_orders')
          purchase_order = TaobaoPurchaseOrder.new(trade)
          sub_orders = sub_orders['sub_purchase_order']
          
          unless sub_orders.is_a?(Array)
            sub_orders = [] << sub_orders
          end 
          
          sub_orders.each do |sub_order|
            sub_order.delete 'id'
            sub_purchase_order = purchase_order.taobao_sub_purchase_orders.build(sub_order)
          end
          purchase_order.save  
          $redis.sadd('TaobaoPurchaseOrderTids', trade['fenxiao_id'])
          
          # 分流 或 拆分订单
          purchase_order.auto_dispatch! unless TradeSplitter.new(purchase_order).split!
        end
        page_no += 1
      end until(page_no > total_pages || total_pages == 0) 
    end

    def update(start_time = nil, end_time = nil)
      total_pages = nil
      page_no = 0

      end_time ||= Time.now
      start_time ||= end_time - 7.days

      begin
        response = TaobaoQuery.get({
          method: 'taobao.fenxiao.orders.get',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 50}, nil
        )
        break unless response['fenxiao_orders_get_response']

        total_results = response['fenxiao_orders_get_response']['total_results']
        total_results = total_results.to_i
        total_pages ||= total_results / 50
        next if total_results < 1 
        trades = response['fenxiao_orders_get_response']['purchase_orders']['purchase_order']
         
        unless trades.is_a?(Array)
          trades = [] << trades
        end   

        trades.each do |trade|
          TaobaoPurchaseOrder.where(tid: trade['fenxiao_id']).each do |local_trade|
            next if trade['status'] == local_trade.status || (trade['status'] == "WAIT_SELLER_SEND_GOODS" && local_trade.delivered_at.present?)
            trade.delete 'id'
            sub_orders = trade.delete('sub_purchase_orders')
            local_trade.update_attributes trade
            local_sub_orders = local_trade.taobao_sub_purchase_orders
            
            sub_purchase_order = sub_orders['sub_purchase_order']
            
            unless sub_purchase_order.is_a?(Array)
              sub_purchase_order = [] << sub_purchase_order
            end  
            
            sub_purchase_order.each do |sub_order|
              sub_order.delete 'id'
              local_sub_order_array = local_sub_orders.select {|o| o.item_id == sub_order['item_id']}
              local_sub_order = local_sub_order_array.first
              next if (local_sub_order.blank? || sub_order['status'] == local_sub_order.status)
              local_sub_order.update_attributes sub_order
            end

            # 分流 
            local_trade.auto_dispatch!

            # 拆分订单
            # TradeSplitter.new(local_trade).split!
          end
        end

        page_no += 1
      end until(page_no > total_pages || total_pages == 0)
    end
  end
end