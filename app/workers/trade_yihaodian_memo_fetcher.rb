# -*- encoding : utf-8 -*-
class TradeYihaodianMemoFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :yihaodian_memo_fetcher, unique: true, unique_job_expiration: 120
  def perform(tid)
    trade = YihaodianTrade.where(tid: tid).first or return
    account = trade.fetch_account

    #一号店有查询发票的接口，需要调用么？

    # 自动将买家备注同步到客服备注
    if account.settings.auto_settings['auto_sync_memo'] && trade.cs_memo.blank?
      result = account.can_auto_preprocess_right_now
      TradeSyncMemo.perform_in(result, trade.tid)
    end
  end
end