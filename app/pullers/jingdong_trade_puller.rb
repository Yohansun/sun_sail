# -*- encoding : utf-8 -*-

class JingdongTradePuller
  class << self
    def create(start_time = nil, end_time = nil)
      total_pages = nil
      page_no = 1
      
      if start_time.blank?  
        latest_created_order = JingdongTrade.only("created").order_by(:created.desc).limit(1).first
        start_time = latest_created_order.created - 1.hour
      end
      
      if end_time.blank?
        end_time = Time.now
      end
  
      p "starting create_orders: since #{start_time}" 
        
      order_states = 'WAIT_SELLER_DELIVERY,WAIT_SELLER_STOCK_OUT,WAIT_GOODS_RECEIVE_CONFIRM,FINISHED_L,TRADE_CANCELED'
      begin 
        response = JingdongFu.get(method: '360buy.order.search',
          order_state: order_states,
          start_date: start_time.strftime("%Y-%m-%d %H:%M:%S"),
          end_date: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page: page_no,
          page_size: 10)
    
        
        total_results = response['order_search_response']['order_search']['order_total']
        total_pages = total_results / 10 
        next if total_results < 1 

        default_seller_id = TradeSetting.default_seller_id

        trades = response['order_search_response']['order_search']['order_info_list']
        next if trades.blank?
        
        trades.each do |t|
          unless ($redis.sismember('JingdongTradeTids', t['order_id']) || JingdongTrade.where(tid: t['order_id']).exists?)
            orders = t.delete('item_info_list')
            trade = JingdongTrade.new(t)
            orders.each do |order|
              order = trade.jingdong_orders.build(order)
            end
            trade.save
            $redis.sadd('JingdongTradeTids',t['order_id'])

            # auto dispatch
            if trade.order_remark.blank? && (trade.order_state == "WAIT_SELLER_DELIVERY" || trade.order_state == "WAIT_SELLER_STOCK_OUT")
              trade.update_attributes(seller_id: default_seller_id, dispatched_at: Time.now)
            end
            p "created new order #{t['order_id']}"
          else
            trade = JingdongTrade.where(tid: t['order_id']).first
            return unless trade
            trade.update_attributes(order_state: t['order_state'], order_state_remark: t['order_state_remark'], order_end_time: t['order_end_time'])
            p "exist order #{t['order_id']}"          
          end
        end
        page_no += 1
      end until(page_no > total_pages || total_pages == 0) 
    end
  end
end
