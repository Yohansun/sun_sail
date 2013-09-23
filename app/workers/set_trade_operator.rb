#encoding: utf-8
class SetTradeOperator
  include Sidekiq::Worker
  sidekiq_options :queue => :puller

  def perform(id)
    trade = Trade.find(id)
    trade.set_operator
  end
end