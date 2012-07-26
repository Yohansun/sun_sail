# -*- encoding : utf-8 -*-
class TradeObserver < Mongoid::Observer

  observe :trade

  def before_save(object)
    if (object.seller_id_changed? && object.seller_id.present?) || (object.dispatched_at_changed? && object.seller_id.present?)
      dispatch_notify(object.id)
    end
  end

  protected
  def dispatch_notify(id)
    TradeDispatchEmail.perform_async(id, 'new')
    TradeDispatchSms.perform_async(id, 'new')
  end
end
