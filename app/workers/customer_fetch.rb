#encoding: utf-8
class CustomerFetch
  include Sidekiq::Worker
  sidekiq_options :queue => :customer_fetch, :retry => false, unique: true, unique_job_expiration: 120

  def perform(account_id=nil,ec_name=nil)
    if account_id && ec_name
      ec_name = ec_name.underscore
      CustomersPuller.send("#{ec_name}_sync",account_id)
      CustomersPuller.send("#{ec_name}_update",account_id)
    else
      CustomersPuller.update(account_id)
      CustomersPuller.sync(account_id)
    end
  end
end