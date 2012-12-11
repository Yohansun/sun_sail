# -*- encoding : utf-8 -*-
class TradeManualSmsNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_manual_notify

  def perform(mobiles, notify_content)
    sms = Sms.new(notify_content, mobiles)
    sms.transmit
  end
  
end