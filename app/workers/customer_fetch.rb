#encoding: utf-8
class CustomerFetch
  include Sidekiq::Worker
  sidekiq_options :queue => :customer_fetch, :retry => false

  def perform(account_id=nil,ec_name=nil)
    if account_id && ec_name
      CustomersPuller.send("#{ec_name}_sync",account_id)
      CustomersPuller.send("#{ec_name}_update",account_id)
    else
      CustomersPuller.update(account_id)
      CustomersPuller.sync(account_id)
    end
  end
end