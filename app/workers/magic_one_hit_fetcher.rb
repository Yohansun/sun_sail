# -*- encoding : utf-8 -*-

class MagicOneHitFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher, :retry => false

  def perform(account_id)
    # more settings here
    TaobaoTradePuller.create(Time.now - 3.month, Time.now, account_id)
    TaobaoLogisticsOrdersPuller.create(Time.now - 3.month, Time.now, account_id)
    TaobaoProductsPuller.create(account_id)
    TaobaoProductsPuller.sync_cat_name(account_id)
    base_url = TradeSetting.base_url
    HTTParty.put("#{base_url}/account_setups/#{account_id}/data_fetch_finish")
  end  
end