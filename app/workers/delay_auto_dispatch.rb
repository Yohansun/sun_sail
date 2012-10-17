# -*- encoding : utf-8 -*-
class DelayAutoDispatch
  include Sidekiq::Worker
  sidekiq_options :queue => :delay_auto_dispatch

  def perform(id)
  	trade = Trade.where(id: id).first
  	return unless trade
   	trade.auto_dispatch!
   	trade.operation_logs.build(operated_at: Time.now, operation: '延时自动分流')
   	trade.save
  end
end