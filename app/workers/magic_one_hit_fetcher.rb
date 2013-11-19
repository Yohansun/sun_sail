# -*- encoding : utf-8 -*-

class MagicOneHitFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher, unique: true, unique_job_expiration: 120

  def perform(trade_source_id)
    trade_source = TradeSource.find(trade_source_id)
    account = Account.find(trade_source.account_id)
    # more settings here
    TaobaoTradePuller.create(Time.now - 3.month, Time.now, trade_source_id)
    TaobaoLogisticsOrdersPuller.create(Time.now - 3.month, Time.now, trade_source_id)
    TaobaoProductsPuller.create_from_trades!(trade_source_id)
    TaobaoProductsPuller.sync_cat_name(trade_source_id)
    base_url = TradeSetting.base_url
    HTTParty.put("#{base_url}/account_setups/#{trade_source.account_id}/data_fetch_finish")
    CustomerFetch.perform_async(trade_source_id)
    account.settings.init_data_ready = true if account.settings["init_data_ready"].nil?
  end
end