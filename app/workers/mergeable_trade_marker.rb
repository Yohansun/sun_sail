# -*- encoding : utf-8 -*-
class MergeableTradeMarker
  include Sidekiq::Worker

  # 自动标注可合并订单和订单自动合并队列
  sidekiq_options :queue => :auto_process, unique: true, unique_job_expiration: 120

  def perform()
    #account = Account.find(id)
    Account.all.each do |account|
      marked_trade_ids = []
      trades = Trade.where(account_id: account.id,
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
    end
    true
  end
end