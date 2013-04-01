# -*- encoding : utf-8 -*-

class MagicOneHitFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher, :retry => false

  def perform(account_id)
    # more settings here
    account = Acccount.find_by_id(account_id)
    trade_sources = account.trade_sources
    return if trade_sources.blank?
    trade_sources.each do |trade_source| 
    TaobaoTradePuller.create(Time.now - 3.month, Time.now, trade_source.id)
      TaobaoLogisticsOrdersPuller.create(Time.now - 3.month, Time.now, trade_source.id)
      TaobaoProductsPuller.create_from_trades(trade_source.id)
      TaobaoProductsPuller.sync_cat_name(trade_source.id)
      base_url = TradeSetting.base_url
      HTTParty.put("#{base_url}/account_setups/#{account_id}/data_fetch_finish")
    end  
  end  
end