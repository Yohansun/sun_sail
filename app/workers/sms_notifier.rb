# -*- encoding : utf-8 -*-
class SmsNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :sms

  def perform(content, mobile, tid, notify_kind)
    sms = Sms.new(content, mobile)
    response = sms.transmit
    trade = TradeDecorator.decorate(Trade.where(tid: tid).first)
    if notify_kind == "before_send_goods"
      trade.operation_logs.build(operated_at: Time.now, operation: "发送付款成功短信到买家手机#{mobile}")
    elsif notify_kind == "after_send_goods"
      trade.operation_logs.build(operated_at: Time.now, operation: "发送发货短信到买家手机#{mobile}")
    end   
    trade.save
  end

end
