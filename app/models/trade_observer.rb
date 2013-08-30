# -*- encoding : utf-8 -*-
class TradeObserver < Mongoid::Observer

  observe :trade

  def around_save(object)

    yield

    if object.status_changed? && object.status == "WAIT_SELLER_SEND_GOODS" && object.pay_time_changed? && object.pay_time.present?
      send_sms_to_buyer(object)
    end

    if object.delivered_at_changed? && object.delivered_at.present? && object.logistic_waybill.present?
      # 发货操作
      object.deliver!
      return
    end

    if object.seller_id_changed? && object.seller_id.present? && object.dispatched_at_changed? && object.dispatched_at.present?
      # 分派操作
      dispatch_notify(object.id, object.seller_id)
    end

    if object.fetch_account.key == "dulux" && object._type == "TaobaoTrade" && object.status_changed? && object.status == "TRADE_FINISHED" && !object.has_sent_send_logistic_rate_sms
      send_rate_sms_to_buyer(object)
      create_rate_record(object)
      object.has_sent_send_logistic_rate_sms = true
    end

    if object.request_return_at_changed? && object.request_return_at.present?
      send_return_sms_to_seller(object)
    end

  end

  protected
  def dispatch_notify(id, seller_id)
    TradeDispatchEmail.perform_async(id, seller_id, 'new')
    TradeDispatchSms.perform_async(id, seller_id, 'new')
  end
  def send_sms_to_buyer(trade)
    trade = TradeDecorator.decorate(trade)
    mobile = trade.receiver_mobile_phone
    trade_tid = trade.tid
    content = "亲您好，感谢您的购买，您的订单号为#{trade_tid}，我们会尽快为您安排发货。【#{trade.fetch_account.settings.shopname_taobao}】"
    notify_kind = "before_send_goods"
    if content && mobile
      SmsNotifier.perform_async(content, mobile, trade_tid ,notify_kind)
    end
  end

  def create_rate_record(trade)
    logistic_id = trade.logistic_id
    seller_id = trade.seller_id
    mobile = trade.receiver_mobile
    tid = trade.tid
    LogisticRate.create(send_at: Time.now, seller_id: seller_id, mobile: mobile, tid: tid, logistic_id: logistic_id)
  end

  def send_rate_sms_to_buyer(trade)
    mobile = trade.receiver_mobile
    trade_tid = trade.tid
    notify_kind = "rate_sms_to_buyer"
    content = "亲，感谢您对【#{trade.fetch_account.settings.shopname_taobao}】的支持，若您对本次物流服务满意请回复“5“，若觉得物流有待提升请回复“3”，若觉得很不满意请回复“1“，本条短信回复免费。【#{trade.fetch_account.settings.shopname_taobao}】"
    if content && mobile
      SmsNotifier.perform_async(content, mobile, trade_tid ,notify_kind)
    end
  end

  def send_return_sms_to_seller(trade)
    trade_decorator = TradeDecorator.decorate(trade)
    content = "#{trade.seller.try(:name)}经销商您好，您有一笔退货订单需要处理。订单号：#{trade.tid}，买家姓名：#{trade_decorator.receiver_name}，手机：#{trade_decorator.receiver_mobile_phone}，请尽快登录系统查看！"
    SmsNotifier.perform_async(content, trade.seller.try(:mobile), trade.tid, 'request_return')
  end
end
