# -*- encoding : utf-8 -*-

class JingdongInitialFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher, unique: true, unique_job_expiration: 120

  def perform(account_id)
    JingdongTradePuller.create(account_id)
  end
end