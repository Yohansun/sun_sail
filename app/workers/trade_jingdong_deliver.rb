# -*- encoding : utf-8 -*-
class TradeJingdongDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :jingdong

  def perform(id)
    jingdong_logistics = {"YTO"=>1499, "ZTO"=>463, "OTHER"=>1274}
    trade = JingdongTrade.find(id)
    return unless trade
    response = JingdongFu.get(
      method: '360buy.order.sop.outstorage', 
      order_id: trade.tid,
      logistics_id: jingdong_logistics[trade.logistic_code || "OTHER"], 
      waybill: trade.logistic_waybill,
      trade_no: trade.tid
    )
    if response['order_sop_outstorage_response']
      response = response['order_sop_outstorage_response']
      code = response['code']
    end
  end
end