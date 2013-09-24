# -*- encoding : utf-8 -*-
class DelayAutoDispatch
  include Sidekiq::Worker
  sidekiq_options :queue => :auto_process, unique: true, unique_job_expiration: 60 #自动分派队列

  def perform(id)
    trade = Trade.where(_id: id).first
    return unless trade

    #异常订单不自动分派
    return if trade.has_unusual_state

    #隐藏拆分逻辑
    # account = trade.fetch_account
    # if account.settings.auto_settings["auto_split"]
    #   if account.can_auto_preprocess_right_now?
    #     can_split = TradeSplitter.new(trade).split!
    #   end
    # else
    #   can_split = false
    # end

    trade.auto_dispatch!

  end
end