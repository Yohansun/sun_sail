# -*- encoding : utf-8 -*-
class JingdongRefundOrderMarker
  include Sidekiq::Worker
  sidekiq_options :queue => :jingdong_refund_order_marker, unique: true, unique_job_expiration: 120

  def perform(trade_source_id)
    start_time = 1.week.ago.strftime("%Y-%m-%d %H:%M:%S")
    end_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    trade_source = TradeSource.find(trade_source_id)
    query_conditions = trade_source.jingdong_query_conditions
    #没有加query_fields,需要加
    data = {parameters: {method: '360buy.after.search',select_fields: 'receive_state,return_item_list',page: 100,page_size: 10}}
    response = JingdongQuery.get(data[:parameters], query_conditions)
    cache_exception(message: "京东退货信息抓取异常(#{trade_source.name})",data: data.merge({response: response,trade_source_id: trade_source_id})) do
      response['after_search_response']['after']["return_infos"].each do |info|
        info['return_item_list'].each do |return_order|
          trade = JingdongTrade.where(tid: return_order['order_id']).first
          return_order = trade.orders.where(sku_id: order['sku_id']).first
          return_order.refund_status = order['return_type']
          return_order.save
        end
      end
    end
  end
end