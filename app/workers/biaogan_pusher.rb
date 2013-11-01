# -*- encoding : utf-8 -*-
class BiaoganPusher
  include Sidekiq::Worker
  sidekiq_options :queue => :biaogan, unique: true, unique_job_expiration: 120
  def perform(bill_id, method)
    bill = StockBill.find(bill_id)
    bill.send(method)
  end
end