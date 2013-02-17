# -*- encoding : utf-8 -*-
class TradeTaobaoPromotionFetcher
	include Sidekiq::Worker
  sidekiq_options :queue => :taobao_promotion_fetcher

  def perform(tid)

    trade = TaobaoTrade.where(tid: tid).first
    return unless trade

    result = TaobaoQuery.get({
      :method => 'taobao.trade.fullinfo.get',
      :fields => 'promotion_details',
      :tid => trade.tid }, trade.trade_source_id
    )

    if promotion_details = result.try(:[], "trade_fullinfo_get_response").try(:[], 'trade').try(:[], 'promotion_details').try(:[], 'promotion_detail')
      trade.promotion_details.delete_all
      promotion_details.each do |pi|
        promotion = trade.promotion_details.new pi
        promotion.oid = pi['id']
        promotion.save
      end
    end

    trade.update_attributes promotion_fee: trade.promotion_details.sum(:discount_fee), got_promotion: true

    delay_time = trade.fetch_account.settings.delay_time || 0

    DelayAutoDispatch.perform_in(delay_time, trade.id)
  end
end
