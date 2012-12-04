# -*- encoding : utf-8 -*-
task :fetch_rate => :environment do
  o=Trade.where(:created => Time.local(2012,11,11,0,0,0)..Time.now).where(:status => "TRADE_FINISHED")
	o.each_with_index do |trade, index|
    logistic_id = trade.logistic_id
    seller_id = trade.seller_id
    mobile = trade.receiver_mobile
    trade_tid = trade.tid
    unless LogisticRate.where(seller_id: seller_id, tid: trade_tid, logistic_id: logistic_id).exists?
      LogisticRate.create(send_at: Time.now, seller_id: seller_id, mobile: mobile, tid: trade_tid, logistic_id: logistic_id)
      notify_kind = "rate_sms_to_buyer"
      content = "亲，感谢您对【#{TradeSetting.shopname_taobao}】的支持，若您对本次物流服务满意请回复“5“，若觉得物流有待提升请回复“3”，若觉得很不满意请回复“1“，本条短信回复免费。【#{TradeSetting.shopname_taobao}】" #TradeSetting.shopname_taobao = "天猫多乐士店"
      if content && mobile
        SmsNotifier.perform_async(content, mobile, trade_tid ,notify_kind)
      end
    end 
    p index 
  end
end