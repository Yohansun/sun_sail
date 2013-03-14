# -*- encoding : utf-8 -*-
class DelayAutoDispatch
  include Sidekiq::Worker
  sidekiq_options :queue => :delay_auto_dispatch

  def perform(id)
    trade = Trade.where(_id: id).first
    return unless trade

    account = trade.fetch_account
    if account.settings.auto_settings["auto_split"]
      if account.can_auto_preprocess_right_now?
        can_split = TradeSplitter.new(trade).split!
      end
    else
      can_split = false
    end

    if account.settings.auto_settings["auto_dispatch"]
      if account.can_auto_dispatch_right_now?
        trade.auto_dispatch! unless can_split
      end
    end

  end
end