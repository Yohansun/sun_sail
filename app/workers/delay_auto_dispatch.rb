# -*- encoding : utf-8 -*-
class DelayAutoDispatch
  include Sidekiq::Worker
  sidekiq_options :queue => :delay_auto_dispatch

  def perform(id)
  	trade = Trade.where(id: id).first
   	trade.auto_dispatch! if trade
  end
end