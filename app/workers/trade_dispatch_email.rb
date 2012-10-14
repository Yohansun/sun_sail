# -*- encoding : utf-8 -*-
class TradeDispatchEmail
  include Sidekiq::Worker
  sidekiq_options :queue => :email

  def perform(id, seller_id, notify_kind)
    Notifier.dispatch(id, seller_id, notify_kind).deliver
  end

end
