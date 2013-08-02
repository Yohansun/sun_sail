# -*- encoding : utf-8 -*-

class JingdongInitialFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher

  def perform(account_id)
    JingdongTradePuller.create(account_id)
  end
end