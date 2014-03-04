class SetForecastSellerWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :puller, unique: true, unique_job_expiration: 120

  def perform(id)
    trade = Trade.where(_id: id).first or return
    if trade.status == "WAIT_SELLER_SEND_GOODS" && trade.forecast_seller_id.blank?
      forecast_seller_id = trade.matched_seller_with_default(nil).id rescue forecast_seller_id = nil
      if forecast_seller_id.present?
        trade.update_attribute(:forecast_seller_id, forecast_seller_id)
      end
    end
  end
end