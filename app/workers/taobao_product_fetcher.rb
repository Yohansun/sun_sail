#encoding: utf-8

class TaobaoProductFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao_product_fetcher, unique: true, unique_job_expiration: 12000

  def perform(account_id)
    Account.find(account_id).taobao_sources.to_a.each do |source|
      TaobaoProductSync.new(source).sync
    end
  end
end