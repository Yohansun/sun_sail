#encoding: utf-8
class SetTradeOperator
  include Sidekiq::Worker
  sidekiq_options :queue => :puller, unique: true, unique_job_expiration: 60

  def perform(id)
    trade = Trade.find(id)
    trade.set_operator
  end
end