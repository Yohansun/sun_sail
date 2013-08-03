# -*- encoding : utf-8 -*-
class JingdongRefundOrderMarker
  include Sidekiq::Worker
  sidekiq_options :queue => :jingdong_refund_order_marker

  def perform(account_id)
    start_time = 1.week.ago.strftime("%Y-%m-%d %H:%M:%S")
    end_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    #没有加query_fields,需要加
    response = JingdongQuery.get({method: '360buy.after.search',
                                  select_fields: 'receive_state,return_item_list',
                                  page: 100,
                                  page_size: 10}, account_id)
    if response['after_search_response']
      return_infos = response['after_search_response']['after']["return_infos"]
      if return_infos.present?
        return_orders = return_infos['return_item_list']
        if return_orders
          return_orders.each do |order|
            trade = JingdongTrade.where(tid: order['order_id']).first
            if trade
              return_order = trade.orders.where(sku_id: order['order_id']).first
              return_order.refund_status = order['return_type']
              return_order.save
            end
          end
        end
      end
    end
  end
end