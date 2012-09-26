module Dulux
	module SellerMatcher
		class << self
			def match_item_seller(area, outer_iid, num)
				return unless num
				product_seller_ids = StockProduct.joins(:product).where("products.iid = '#{outer_iid}' AND stock_products.activity > #{num}").map &:seller_id
				area.sellers.where(id: product_seller_ids).reorder("performance_score DESC").first
			end

			def match_trade_seller(trade, area)
				order = trade.orders.first
				match_item_seller(area, order.item_outer_id, order.num)
			end
		end
	end

	module Splitter
		def split_orders(trade)
			area = trade.default_area
	    return unless area

	    all_orders = trade.orders

	    grouped_orders = {}
	    splitted_orders = []

	    all_orders.each do |order|
				seller = Dulux::SellerMatcher.match_item_seller(area, order.item_outer_id, order.num)
				seller_id = seller ? seller.id : 0
				tmp = grouped_orders["#{seller_id}"] || []
				tmp << order
				grouped_orders["#{seller_id}"] = tmp
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