# -*- encoding : utf-8 -*-
class TradeTaobaoAutoDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_taobao_auto_deliver

  def perform(id)
    trade = Trade.find(id)
    trade.delivered_at = Time.now
    trade.status = 'WAIT_BUYER_CONFIRM_GOODS'
    trade.save   #observer会自动调用deliver
    trade.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
  end
end