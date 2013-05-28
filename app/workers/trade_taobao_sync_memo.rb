# -*- encoding : utf-8 -*-
class TradeTaobaoSyncMemo
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao_memo_sync
  def perform(tid)
    trade = TaobaoTrade.where(tid: tid).first
    trade.update_attributes(cs_memo: trade.buyer_message) if trade.buyer_message
    trade.save
  end
end