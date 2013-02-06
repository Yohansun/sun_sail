# -*- encoding : utf-8 -*-

class MagicOneHitFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher, :retry => false

  def perform(id)
  	TaobaoTradePuller.create
  	TaobaoLogisticsOrdersPuller.create
  	TaobaoProductsPuller.create(id)
  	TaobaoProductsPuller.sync_cat_name(id)
  end 	
end