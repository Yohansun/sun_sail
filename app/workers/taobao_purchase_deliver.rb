# -*- encoding : utf-8 -*-
class TradeTaobaoDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao_purchase

  def perform(id)
    trade = TaobaoPurchaseOrder.find(id)
    response = TaobaoFu.get :method => 'taobao.logistics.offline.send', :tid => trade.tid,
      :out_sid => trade.logistic_waybill,
      :company_code => trade.logistic_code 

    if response['delivery_offline_send_response']
      response = response['delivery_offline_send_response']['shipping']
      code = response['is_succsess']
    end
  end
end