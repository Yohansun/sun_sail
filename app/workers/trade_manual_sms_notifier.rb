# -*- encoding : utf-8 -*-
class TradeManualSmsNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_manual_notify, unique: true, unique_job_expiration: 60

  def perform(account_id, mobiles, notify_content)
    account = Account.find(account_id)
    sms = Sms.new(account, notify_content, mobiles)
    sms.transmit
  end

end