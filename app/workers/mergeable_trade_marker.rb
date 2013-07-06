# -*- encoding : utf-8 -*-
class MergeableTradeMarker
  include Sidekiq::Worker
  sidekiq_options :queue => :mergeable_trade_marker

  def perform(id)
    account = Account.find(id)
    marked_trade_ids = []
    trades = Trade.where(account_id: id,
                         status: "WAIT_SELLER_SEND_GOODS",
                         main_trade_id: nil)
    if account.settings.auto_settings && account.settings.auto_settings["auto_merge"] != 1
      trades.each do |trade|
        unless marked_trade_ids.include?(trade.id)
          marked_trade_ids << trade.mark_mergable_trades
          marked_trade_ids = marked_trade_ids.flatten.compact
        end
      end
    else
      trades.each do |trade|
        unless marked_trade_ids.include?(trade.id)
          marked_trade_ids << trade.trig_auto_merge
          marked_trade_ids = marked_trade_ids.flatten.compact
        end
      end
    end

    MergeableTradeMarker.perform_in(5.minutes, id)
    true
  end
end