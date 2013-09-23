# -*- encoding : utf-8 -*-
class TradeTaobaoSyncMemo
  include Sidekiq::Worker
  sidekiq_options :queue => :auto_process #自动同步备注队列
  def perform(tid)
    trade = TaobaoTrade.where(tid: tid).first
    trade.update_attributes(cs_memo: trade.buyer_message) if trade.buyer_message
  end
end