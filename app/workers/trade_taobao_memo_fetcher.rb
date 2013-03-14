# -*- encoding : utf-8 -*-
class TradeTaobaoMemoFetcher
	include Sidekiq::Worker
  sidekiq_options :queue => :taobao_memo_fetcher

  def perform(tid)
    if tid.slice!(/_G[0-9]$/) == nil #NEED ADAPTION?
      trade = TaobaoTrade.where(tid: tid).first
      return unless trade
      source_id = trade.trade_source_id
      response = TaobaoQuery.get({
        method: 'taobao.trade.get',
        fields: 'buyer_message, seller_memo',
        tid: tid}, source_id
      )
      return unless response && response["trade_get_response"]
      remote_trade = response["trade_get_response"]["trade"]
      return unless remote_trade
      trade.update_attributes(buyer_message: remote_trade['buyer_message']) if remote_trade['buyer_message']
      trade.update_attributes(seller_memo: remote_trade['seller_memo']) if remote_trade['seller_memo']
      trade.save
    end
  end

end