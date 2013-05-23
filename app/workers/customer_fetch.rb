#encoding: utf-8
class CustomerFetch
  include Sidekiq::Worker
  sidekiq_options :queue => :customer_fetch
  
  def perform
    CustomersPuller.update
    CustomersPuller.sync
  end
end