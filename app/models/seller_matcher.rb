class SellerMatcher
	def self.match_item_seller(area, order)
		match_item_sellers(area, order).first
	end

	def self.match_item_sellers(area, order)
		sellers = nil
		taobao_product = TaobaoProduct.find_by_outer_id order.outer_iid
		return [] unless taobao_product
		color_num = order.color_num
		color_num.delete('')
		op_package = taobao_product.package_info
		op_package << {
		outer_id: order.outer_iid,
		number: order.num,
		title: order.title
		} if op_package.blank?

		op_package.each do |pp|
			sql = "products.outer_id = '#{pp[:outer_id]}' AND stock_products.activity > #{pp[:number]}"
			products = StockProduct.joins(:product).where(sql)

			if op.account.settings.enable_match_seller_user_color && color_num.present?
				color_num.each do |colors|
					next if colors.blank?
					colors = colors.shift(pp[:number]).flatten.compact.uniq
					colors.delete('')
					products = products.select {|p| (colors - p.colors.map(&:num)).size == 0}
				end
			end

			product_seller_ids = products.map &:seller_id
			a_sellers = area.sellers.where(id: product_seller_ids, active: true, account_id: order.account_id).reorder("performance_score DESC")
			if sellers
				sellers = sellers & a_sellers
			else
				sellers = a_sellers
			end
		end
		sellers
	end	

	def self.match_trade_seller(trade, area)
		matched_sellers = nil
		trade.orders.each do |o|
			matched_sellers ||= match_item_sellers(area, o)
			matched_sellers = matched_sellers & match_item_sellers(area, o)
		end
		matched_sellers ||= []
		matched_sellers.first
	end	
end	
