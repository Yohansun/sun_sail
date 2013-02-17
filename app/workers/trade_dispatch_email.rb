# -*- encoding : utf-8 -*-
class TradeDispatchEmail
  include Sidekiq::Worker
  sidekiq_options :queue => :email

  def perform(id, seller_id, notify_kind)
    trade = Trade.find id
    seller = Seller.find seller_id
    email_operation = "发送邮件"

    if trade.fetch_account.settings.enable_module_interface == 0
      to_emails = seller.email.try(:split, ',')
    else
      to_emails = seller.interface_email
    end

    if to_emails.present?
      Notifier.dispatch(id, seller_id, notify_kind).deliver
      email_operation += "到#{seller.email}"
    else
      email_operation += "失败，经销商没有绑定邮件"
    end

    trade.operation_logs.create!(operated_at: Time.now, operation: email_operation)

  end
end
