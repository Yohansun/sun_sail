#encoding: utf-8
class SetAlipayDataWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :puller, unique: true, unique_job_expiration: 120

  def perform(id)
    trade = Trade.where(_id: id).first or return
    trade.set_alipay_data
    trade.save
  end
end