class SellerMatcher
	
	def initialize(trade)
		@trade = trade 
	end

	def matched_seller(area)
		all_special_products_seller || area_seller(area)
	end

protected

	def area_seller(area)
    return if area.blank?
    area.sellers.first
	end

	def all_special_products_seller
		# TODO
		# 完善的匹配规则
		seller = nil

		special_out_iids = TaobaoPurchaseOrderSplitter.splitable_maps['1720']
		trade_out_iids = @trade.out_iids || []

		if trade_out_iids.size > 0 && (trade_out_iids - special_out_iids).size == 0
			seller = Seller.find 1720
		end

		seller
	end
end