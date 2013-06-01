#encoding: utf-8
class CustomerFetch
  include Sidekiq::Worker
  sidekiq_options :queue => :customer_fetch
  
  def perform(account_id=nil)
    CustomersPuller.update(account_id)
    CustomersPuller.sync(account_id)
  end
end