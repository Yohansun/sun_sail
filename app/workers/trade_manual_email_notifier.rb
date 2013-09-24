# -*- encoding : utf-8 -*-
class TradeManualEmailNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_manual_notify, unique: true, unique_job_expiration: 60

  def perform(mails, notify_content, notify_theme, account_id)
    Notifier.manual_notify(mails, notify_content, notify_theme, account_id).deliver
  end
end