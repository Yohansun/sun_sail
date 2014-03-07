#encoding: utf-8
class YihaodianProductFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :yihaodian_product_fetcher, unique: true, unique_job_expiration: 12000

  def perform(account_id)
    Account.find(account_id).yihaodian_sources.to_a.each do |source|
      YihaodianProductSync.new(source).sync
    end
  end
end