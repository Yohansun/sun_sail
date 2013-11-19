#encoding: utf-8
class CustomerFetch
  include Sidekiq::Worker
  sidekiq_options :queue => :customer_fetch, :retry => false, unique: true, unique_job_expiration: 120

  def perform(trade_source_id=nil,ec_name=nil)
    if trade_source_id && ec_name
      ec_name = ec_name.underscore
      CustomersPuller.send("#{ec_name}_sync",trade_source_id)
      CustomersPuller.send("#{ec_name}_update",trade_source_id)
    else
      CustomersPuller.update(trade_source_id)
      CustomersPuller.sync(trade_source_id)
    end
  end
end