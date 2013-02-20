# -*- encoding : utf-8 -*-
class TradeManualSmsNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_manual_notify

  def perform(account_id, mobiles, notify_content)
    sms = Sms.new(Account.find_by_id(account_id), notify_content, mobiles)
    sms.transmit
  end
  
end