# -*- encoding : utf-8 -*-
class TradeTaobaoMemoFetcher
	include Sidekiq::Worker
  sidekiq_options :queue => :taobao_memo_fetcher

  def perform(id)
    trade = TaobaoTrade.find(id)
    return unless trade
    
    TaobaoFu.select_source(trade.trade_source_id)

    response = TaobaoFu.get(
    	method: 'taobao.trade.get',
      fields: 'buyer_message',
      tid: trade.tid
    )

    return unless response && response["trade_get_response"]
    remote_trade = response["trade_get_response"]["trade"]

    trade.update_attributes(buyer_message: remote_trade['buyer_message'], seller_memo: remote_trade['seller_memo'])
  end
end