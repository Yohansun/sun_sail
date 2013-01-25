# -*- encoding : utf-8 -*-
class SmsNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :sms

  def perform(content, mobile, tid, notify_kind)
    trade = Trade.where(tid: tid).first
    sms = Sms.new(content, mobile)
    success = false
    success = true if TradeSetting.company == "dulux" && sms.transmit.parsed_response == "0"
    success = true if TradeSetting.company == "nippon" && sms.transmit.fetch(:description) == "成功"

    if success 
      operation = case notify_kind
                  when "before_send_goods"
                    "发送付款成功短信到买家手机#{mobile}"
                  when "after_send_goods"
                    "发送发货短信到买家手机#{mobile}"
                  when "rate_sms_to_buyer"
                    "发送物流评分短信到买家手机#{mobile}"
                  when "request_return"
                    "发送退货提醒短信到卖家手机#{mobile}"
                  end
    else
      operation = "发送短信到买家手机#{mobile}失败，请检查短信平台是否正常连接"
    end

    trade.operation_logs.create(operated_at: Time.now, operation: operation)
  end
end
