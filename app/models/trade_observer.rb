# -*- encoding : utf-8 -*-
class TradeObserver < Mongoid::Observer

  observe :trade
  
  def after_create(object)
    send_sms_to_buyer(object)
  end

  def before_update(object)
    cloumns = object.changed
    if cloumns.include?("status")
      @flag = true
    end
  end

  def after_update(object)
    if @flag
      send_sms_to_buyer(object)
    end
    @flag = false
  end

  def before_save(object)
    if object.delivered_at_changed? && object.delivered_at.present?
      # 发货操作
      object.deliver!
      object.status = 'WAIT_BUYER_CONFIRM_GOODS'
      return
    end

    if object.seller_id_changed? && object.seller_id.present? && object.dispatched_at_changed? && object.dispatched_at.present?
      # 分流操作
      if dispatch_notify(object.id, object.seller_id)
        sms_operation = "发送短信到#{object.seller.mobile}"
        email_operation = "发送邮件到#{object.seller.email}"
        object.operation_logs.build(operated_at: Time.now, operation: sms_operation)
        object.operation_logs.build(operated_at: Time.now, operation: email_operation)
      end
    end
  end

  protected
  def dispatch_notify(id, seller_id)
    TradeDispatchEmail.perform_async(id, seller_id, 'new')
    TradeDispatchSms.perform_async(id, seller_id, 'new')
  end 
  def send_sms_to_buyer(trade)
    trade = TradeDecorator.decorate(trade)
    content = nil
    notify_kind = nil 
    mobile = trade.receiver_mobile_phone
    trade_tid = trade.tid
    status = trade.status
    case status
    when "WAIT_SELLER_SEND_GOODS"
      content = "亲您好，感谢您的购买，您的订单号为#{trade_tid}，我们会尽快为您安排发货。【天猫多乐士店】"
      notify_kind = "before_send_goods"
    when "WAIT_BUYER_CONFIRM_GOODS"
      if trade.splitted?
        content = "亲您好，您的订单#{trade_tid}已经发货，该订单将由地区发送，请注意查收。【天猫多乐士店】"
      else
        content = "亲您好，您的订单#{trade_tid}已经发货，我们将尽快为您送达，请注意查收。【天猫多乐士店】"
      end
      notify_kind = "after_send_goods"
    end
    if content && mobile
      SmsNotifier.perform_async(content, mobile, trade_tid ,notify_kind)
    end
  end
end