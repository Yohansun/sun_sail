# -*- encoding : utf-8 -*-
class TradeTaobaoMemoFetcher
	include Sidekiq::Worker
  sidekiq_options :queue => :taobao_memo_fetcher

  def perform(tid, trade_source_id)
    TaobaoFu.select_source(trade_source_id)

    response = TaobaoFu.get(
    	method: 'taobao.trade.get',
      fields: 'buyer_message',
      tid: tid
    )

    return unless response && response["trade_get_response"]
    remote_trade = response["trade_get_response"]["trade"]

    TaobaoTrade.where(tid: tid).update_all(buyer_message: remote_trade['buyer_message'])
  end
end