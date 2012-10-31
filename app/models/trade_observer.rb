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
      # 分流操作
      dispatch_notify(object.id, object.seller_id)
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
    content = "亲您好，感谢您的购买，您的订单号为#{trade_tid}，我们会尽快为您安排发货。【#{TradeSetting.shopname_taobao}】" #TradeSetting.shopname_taobao = "天猫多乐士店"
    notify_kind = "before_send_goods"
    if content && mobile
      SmsNotifier.perform_async(content, mobile, trade_tid ,notify_kind)
    end
  end
end