# -*- encoding : utf-8 -*-
class TradeJingdongDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_jingdong_deliver

  def perform(id)
    jingdong_logistics = {"YTO"=>1499, "ZTO"=>463, "OTHER"=>1274}
    trade = JingdongTrade.find(id)
    query_conditions = Account.find(trade.account_id).jingdong_query_conditions
    return unless trade
    response = JingdongQuery.get({method: '360buy.order.sop.outstorage',
                                  order_id: trade.tid,
                                  logistics_id: jingdong_logistics[trade.logistic_code || "OTHER"],
                                  waybill: trade.logistic_waybill,
                                  trade_no: trade.tid
                                  }, query_conditions
                                )
    if response['order_sop_outstorage_response']
      response = response['order_sop_outstorage_response']
      code = response['code']
    end
  end
end