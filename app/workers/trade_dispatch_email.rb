# -*- encoding : utf-8 -*-
class TradeDispatchEmail
  include Sidekiq::Worker
  sidekiq_options :queue => :email

  def perform(id, seller_id, notify_kind)
    Notifier.dispatch(id, seller_id, notify_kind).deliver
    trade = Trade.find id
    seller = Seller.find seller_id
 		email_operation = "发送邮件"
    if seller.email.present?
      email_operation += "到#{seller.email}"
    else
      email_operation += "失败，经销商没有绑定邮件"  
    end
 		trade.operation_logs.create!(operated_at: Time.now, operation: email_operation)
  end	
end
