# -*- encoding : utf-8 -*-

class YihaodianInitialFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :one_hit_fetcher, unique: true, unique_job_expiration: 120

  def perform(trade_source_id)
    YihaodianTradePuller.create_with_source(trade_source_id)
  end
end