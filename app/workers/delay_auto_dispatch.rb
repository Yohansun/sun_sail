# -*- encoding : utf-8 -*-
class DelayAutoDispatch
  include Sidekiq::Worker
  sidekiq_options :queue => :delay_auto_dispatch

  def perform(id)
  	trade = Trade.where(id: id).first
  	return unless trade
   	trade.auto_dispatch!
   	trade.save
  end
end