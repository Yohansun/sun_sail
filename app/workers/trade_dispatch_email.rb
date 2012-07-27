# -*- encoding : utf-8 -*-
class TradeDispatchEmail
  include Sidekiq::Worker
  sidekiq_options :queue => :email

  def perform(id, notify_kind)
    Notifier.dispatch(id, notify_kind).deliver
  end

end
