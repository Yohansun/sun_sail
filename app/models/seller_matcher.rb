class SellerMatcher
	
	def initialize(trade)
		@trade = trade
	end

	def matched_seller(area)
		all_special_products_seller || area_seller(area)
	end

protected

	def area_seller(area)
    area.sellers.first
	end

	def all_special_products_seller
		# TODO
		# 完善的匹配规则
		seller = nil
		
    default_seller_id = TradeSetting.default_seller_id

		special_out_iids = TaobaoPurchaseOrderSplitter.splitable_maps[default_seller_id]
		trade_out_iids = @trade.out_iids || []

		if trade_out_iids.size > 0 && (trade_out_iids - special_out_iids).size == 0
			seller = Seller.find default_seller_id
		end

		seller
	end
end