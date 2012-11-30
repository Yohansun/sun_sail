# -*- encoding : utf-8 -*-
class SmsNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :sms

  def perform(content, mobile, tid, notify_kind)
    trade = Trade.where(tid: tid).first
    sms = Sms.new(content, mobile)
    response = sms.transmit.parsed_response
    if response == '0' 
      if notify_kind == "before_send_goods"
        trade.operation_logs.create(operated_at: Time.now, operation: "发送付款成功短信到买家手机#{mobile}")
      elsif notify_kind == "after_send_goods"
        trade.operation_logs.create(operated_at: Time.now, operation: "发送发货短信到买家手机#{mobile}")
      elsif notify_kind == "rate_sms_to_buyer"
        trade.operation_logs.create(operated_at: Time.now, operation: "发送物流评分短信到买家手机#{mobile}")
      end   
    else
      trade.operation_logs.create(operated_at: Time.now, operation: "发送短信到买家手机#{mobile}失败，请检查短信平台是否正常连接")
    end    
  end

end
