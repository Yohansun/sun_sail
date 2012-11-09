# -*- encoding : utf-8 -*-
class TradeTaobaoMemoFetcher
	include Sidekiq::Worker
  sidekiq_options :queue => :taobao_memo_fetcher
  
  def perform(tid)
    trade = TaobaoTrade.where(tid: tid).first
    response = TaobaoQuery.get({
      method: 'taobao.trade.get',
      fields: 'buyer_message',
      tid: tid}, trade.try(:trade_source_id)
    )

    return unless response && response["trade_get_response"]
    remote_trade = response["trade_get_response"]["trade"]

    trade.update_attributes(buyer_message: remote_trade['buyer_message'])
    trade.operation_logs.build(operated_at: Time.now, operation: '从淘宝抓取留言')
    trade.save
  end

  def self.perform(*args)
    args.each do |tid|
      TradeTaobaoMemoFetcher.new.perform(tid)
    end
  end  
  
end