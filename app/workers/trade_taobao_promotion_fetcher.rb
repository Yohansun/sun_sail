# -*- encoding : utf-8 -*-
class TradeTaobaoPromotionFetcher
	include Sidekiq::Worker
  sidekiq_options :queue => :taobao_promotion_fetcher
  
  def perform(tid)
    
    trade = TaobaoTrade.where(tid: tid).first
    
    result = TaobaoQuery.get({
      :method => 'taobao.trade.fullinfo.get',
      :fields => 'promotion_details',
      :tid => tid }, trade.try(:trade_source_id)
    )

    if result["trade_fullinfo_get_response"] && result["trade_fullinfo_get_response"]['trade'] &&
        result["trade_fullinfo_get_response"]["trade"]["promotion_details"]
      promotion_details = result["trade_fullinfo_get_response"]["trade"]["promotion_details"]["promotion_detail"]
      if promotion_details.to_a.present?
        promotion_details.to_a.each do |pi|
          trade.promotion_details.create(
              :id => pi["id"],
              :promotion_id => pi["promotion_id"],
              :promotion_name => pi["promotion_name"],
              :promotion_desc => pi["promotion_desc"],
              :discount_fee => pi["discount_fee"]
          )
        end
      end
    end
  end 
  
end