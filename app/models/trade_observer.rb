# -*- encoding : utf-8 -*-
class TradeObserver < Mongoid::Observer

  observe :trade

  def before_save(object)
    if object.delivered_at_changed? && object.delivered_at.present?
      # 发货操作
      object.deliver!
      return
    end

    if (object.seller_id_changed? && object.seller_id.present?) || (object.dispatched_at_changed? && object.seller_id.present?)
      # 分流操作
      dispatch_notify(object.id)
    end
  end

  protected
  def dispatch_notify(id)
    TradeDispatchEmail.perform_async(id, 'new')
    TradeDispatchSms.perform_async(id, 'new')
  end
end