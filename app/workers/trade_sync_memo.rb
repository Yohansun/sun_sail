# -*- encoding : utf-8 -*-
class TradeSyncMemo
  include Sidekiq::Worker
  sidekiq_options :queue => :auto_process, unique: true, unique_job_expiration: 120 #自动同步备注队列
  def perform(tid)
    trade = Trade.where(tid: tid).first
    trade.update_attributes(cs_memo: trade.buyer_message) if trade && trade.buyer_message
  end
end