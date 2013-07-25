# -*- encoding : utf-8 -*-

class MagicOneHitFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher

  def perform(account_id)
    # more settings here
    account = Account.find_by_id(account_id)
    if !Trade.where(account_id: account_id).exists? && !Product.where(account_id: account_id).exists?
      trade_sources = account.trade_sources
      return if trade_sources.blank?
      trade_sources.each do |trade_source|
        unless
        TaobaoTradePuller.create(Time.now - 3.month, Time.now, trade_source.id)
        TaobaoLogisticsOrdersPuller.create(Time.now - 3.month, Time.now, trade_source.id)
        TaobaoProductsPuller.create_from_trades!(trade_source.id)
        TaobaoProductsPuller.sync_cat_name(trade_source.id)
        base_url = TradeSetting.base_url
        HTTParty.put("#{base_url}/account_setups/#{account_id}/data_fetch_finish")
      end
      CustomerFetch.perform_async
      account.settings.init_data_ready = true
    end
  end
end