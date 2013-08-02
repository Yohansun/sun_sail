# -*- encoding : utf-8 -*-
class TradeJingdongMemoFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :jingdong_memo_fetcher
  def perform(tid)
    trade = JingdongTrade.where(tid: tid).first
    return unless trade && trade._type != "CustomTrade"
    source_id = trade.trade_source_id
    account = trade.fetch_account
    #PENDING 接口怎么写？
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

    # 自动从memo导入发票抬头
    if account.settings.open_auto_mark_invoice == 1
      if trade.buyer_message
        invoice_buyer = trade.buyer_message.scan(/\$.*\$/).present? ? trade.buyer_message.scan(/\$.*\$/).first : nil
      end
      if trade.seller_memo
        invoice_seller = trade.seller_memo.scan(/\$.*\$/).present? ? trade.seller_memo.scan(/\$.*\$/).first : nil
      end
      invoice_name = (invoice_seller || invoice_buyer)
      if invoice_name.present?
        invoice_name.slice!(0)
        invoice_name.slice!(-1)
      else
        invoice_name = "个人"
      end
      trade.invoice_name = invoice_name
      trade.invoice_type = "需要开票"
      trade.save
    end

    # 自动将买家备注同步到客服备注
    if account.settings.auto_settings['auto_sync_memo'] && trade.cs_memo.blank?
      result = account.can_auto_preprocess_right_now
      if result == true
        TradeSyncMemo.perform_in(account.settings.auto_settings['preprocess_silent_gap'].to_i.hours, trade.tid)
      else
        TradeSyncMemo.perform_in(result, trade.tid)
      end
    end
  end
end