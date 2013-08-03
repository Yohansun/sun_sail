# -*- encoding : utf-8 -*-
class TradeAutoDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :auto_process #自动发货队列

  def perform(id)
    trade = Trade.find(id)
    trade.delivered_at = Time.now
    trade.change_status_to_deliverd
    trade.save   #observer会自动调用deliver
    trade.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
  end
end