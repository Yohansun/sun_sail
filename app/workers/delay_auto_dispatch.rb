# -*- encoding : utf-8 -*-
class DelayAutoDispatch
  include Sidekiq::Worker
  sidekiq_options :queue => :delay_auto_dispatch

  def perform(id)
    trade = Trade.where(_id: id).first
    return unless trade
    trade.auto_dispatch! unless TradeSplitter.new(trade).split!

    # account = trade.fetch_account
    # if account.settings.auto_settings["auto_split"]
    #   if account.can_auto_preprocess_right_now?
    #     can_split = TradeSplitter.new(trade).split!
    #   end
    # else
    #   can_split = false
    # end
  end
end