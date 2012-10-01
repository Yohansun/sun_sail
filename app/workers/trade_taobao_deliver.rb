# -*- encoding : utf-8 -*-
class TradeTaobaoDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao
  
  def perform2(id)
    trade = TaobaoTrade.find(id)
    source = trade.trade_source
    source_name = nil
    if source 
     source_name = source.name
    end
    response = TaobaoQuery.get({
      method: 'taobao.logistics.offline.send',
      tid: trade.tid,
      out_sid: trade.logistic_waybill,
      company_code: trade.logistic_code}, source_name
    )

    if response['delivery_offline_send_response']
      response = response['delivery_offline_send_response']['shipping']
      code = response['is_succsess']
    end
  end

  def perform(id)
    trade = TaobaoTrade.find(id)

    TaobaoFu.select_source(trade.trade_source_id)
    
    response = TaobaoFu.get(
      method: 'taobao.logistics.offline.send',
      tid: trade.tid,
      out_sid: trade.logistic_waybill,
      company_code: trade.logistic_code
    )

    if response['delivery_offline_send_response']
      response = response['delivery_offline_send_response']['shipping']
      code = response['is_succsess']
    end
  end
end
