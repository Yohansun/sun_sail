#encoding: utf-8
class CustomerMessage
  include Sidekiq::Worker
  sidekiq_options :queue => :customer_message
  
  def perform(message)
    if message.send_type_sms?
      account = message.account
      notify_content = message.title + "\;" + message.content
      sms = Sms.new(account, notify_content, message.recipients)
      sms.transmit
    elsif message.send_type_mail?
      CustomersNotifier.around(message).deliver
    end
  end
end