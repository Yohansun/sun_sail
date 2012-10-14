# -*- encoding : utf-8 -*-
class TradeObserver < Mongoid::Observer

  observe :trade

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
end