#encoding: utf-8
class SetHasOnsiteServiceWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :puller

  def perform(id)
    trade = Trade.find(id)
    trade.set_has_onsite_service
    trade.save
  end
end