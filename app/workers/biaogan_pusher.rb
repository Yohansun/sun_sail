# -*- encoding : utf-8 -*-
class BiaoganPusher
  include Sidekiq::Worker
  sidekiq_options :queue => :biaogan, unique: true, unique_job_expiration: 120
  def perform(bill_id, method)
    bill = StockBill.find(bill_id)
    bill.send(method)
  end

  def self.check
    Account.biaoganer.each do |account_id|
      ids =  StockOutBill.where(account_id: account_id,status: 'SYNCKING').distinct(:id)
      ids.each do |bill_id|
        payload_hash = SidekiqUniqueJobs::PayloadHelper.get_payload('BiaoganPusher',:biaogan, [bill_id,"so_to_wms_worker"])
        if Sidekiq.redis {|conn| !conn.exists(payload_hash)}
          BiaoganPusher.perform_async(bill_id, "so_to_wms_worker")
          Rails.logger.warn "BiaoganPussher lost. args: {bill_id: #{bill_id},method: so_to_wms_worker}"
        end
      end
    end
  end
end