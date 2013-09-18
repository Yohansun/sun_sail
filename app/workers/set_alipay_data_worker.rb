#encoding: utf-8
class SetAlipayDataWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :puller

  def perform(id)
    trade = Trade.find(id)
    trade.set_alipay_data
    trade.save
  end
end