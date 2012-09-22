module Dulux
	module SellerMatcher
		class << self
			def match_item_seller(area, outer_iid, num)
				return unless area
				product_seller_ids = StockProduct.joins(:product).where("products.iid = '#{outer_iid}' AND stock_products.activity > #{num}").map &:seller_id
				seller = area.sellers.where(id: product_seller_ids).reorder("performance_score DESC").first
				seller || Seller.find(1720)
			end

			def match_trade_seller(trade, area_id = nil)
				order = trade.orders.first
				area = Area.find_by_id(area_id) || trade.area
				match_item_seller(area, order.item_outer_id, order.num)
			end
		end
	end

	module Splitter
		def split_orders(trade)
	    all_orders = trade.orders
	    area = trade.area
	    grouped_orders = {}
	    splitted_orders = []

	    all_orders.each do |order|
				seller = Dulux::SellerMatcher.match_item_seller(area, order.item_outer_id, order.num)
				tmp = grouped_orders["#{seller.id}"] || []
				tmp << order
				grouped_orders["#{seller.id}"] = tmp
	    end

	    grouped_orders.each do |key, value|
	    	splitted_orders << {
	    		orders: value,
	    		post_fee: 0,
	    		total_fee: value.inject(0) { |sum, el| sum + el.total_fee }
	    	}
	    end

	    splitted_orders
	  end
	end
end