module Dulux
	module SellerMatcher
		class << self
			def match_item_seller(area, order, color)
				product_seller_ids = StockProduct.joins(:product, :colors).where("products.iid = '#{order.outer_iid}' AND stock_products.activity > #{order.num} AND colors.num = '#{color}'").map &:seller_id
				area.sellers.where(id: product_seller_ids, active: true).reorder("performance_score DESC").first
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
	    color_map = color_from_memo(trade.seller_memo)

	    grouped_orders = {}
	    splitted_orders = []

	    all_orders.each do |order|
	    	split_by_color(order, color_map[order.item_outer_id]).each do |o|
					seller = Dulux::SellerMatcher.match_item_seller(area, o.order, o.color)
					seller_id = seller ? seller.id : 0
					grouped_orders["#{seller_id}"] ||= []
					grouped_orders["#{seller_id}"] << o.order
				end
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

	  def color_from_memo(seller_memo)
	  	color_map = {}
	  	return color_map unless seller_memo

	  	seller_memo.gsub!(" ", '')
	  	color_list = seller_memo.split(/[\[\]]/)

	  	color_list.each do |color|
	  		color = color.split(',')
	  		return unless color.size == 3
	  		color_map["#{color[0]}"] = []
	  		color_map["#{color[0]}"] << {
	  			num: color[1],
	  			color: color[2]
	  		}
	  	end

	  	color_map
	  end

	  def split_by_color(order, color_map)
	  	tmp = []
	  	if color_map
	  		color_map.each do |color|
	  			clone_order = order.clone
	  			clone_order.num = color.num
	  			order.num = order.num - color.num.to_i
	  			tmp << {order: clone_order, color: color.color}
	  		end
	  	end
	  	tmp << {order: order, color: nil}
	  end
	end
end




