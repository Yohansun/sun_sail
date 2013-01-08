class OrderDecorator < Draper::Base
  decorates :order

	def item_id
		case order._type
		when 'TaobaoSubPurchaseOrder'
			order.item_id
		when 'TaobaoOrder'
			order.oid
		when 'JingdongOrder'
			order.sku_id
		end
	end

	def sku_properties
		case order._type
		when 'TaobaoSubPurchaseOrder'
			order.sku_properties
		when 'TaobaoOrder'
			order.sku_properties_name
		when 'JingdongOrder'
			''
		end
	end

	def item_outer_id
		case order._type
		when 'TaobaoSubPurchaseOrder'
			order.item_outer_id
		when 'TaobaoOrder'
			order.outer_iid
		when 'JingdongOrder'
			order.outer_sku_id
		end
	end

	def title
		case order._type
		when 'TaobaoSubPurchaseOrder'
			order.title
		when 'TaobaoOrder'
			order.title
		when 'JingdongOrder'
			order.sku_name
		end
	end

	def num
		case order._type
		when 'TaobaoSubPurchaseOrder'
			order.num
		when 'TaobaoOrder'
			order.num
		when 'JingdongOrder'
			order.item_total
		end
	end

	def price
		case order._type
		when 'TaobaoSubPurchaseOrder'
			order.auction_price
	      when 'TaobaoOrder'
			order.price
		when 'JingdongOrder'
			order.jd_price
		end
	end

end
