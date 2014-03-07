#encoding: utf-8

class JingdongProductFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :jingdong_product_fetcher, unique: true, unique_job_expiration: 12000

  def perform(account_id)
    Account.find(account_id).jingdong_sources.to_a.each do |source|
      JingdongProductSync.new(source).sync
    end
  end
end