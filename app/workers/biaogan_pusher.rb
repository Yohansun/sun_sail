# -*- encoding : utf-8 -*-
class BiaoganPusher
  include Sidekiq::Worker
  sidekiq_options :queue => :biaogan
  def perform(bill_id, method)
    bill = StockBill.find(bill_id)
    bill.send(method)
  end
end