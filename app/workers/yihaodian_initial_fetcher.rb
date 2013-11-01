# -*- encoding : utf-8 -*-

class YihaodianInitialFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher, unique: true, unique_job_expiration: 120

  def perform(account_id)
    YihaodianTradePuller.create(account_id)
  end
end