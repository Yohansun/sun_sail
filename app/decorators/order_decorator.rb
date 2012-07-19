class OrderDecorator < Draper::Base
  decorates :order

	 def item_id
	   case order._type	
	   when 'TaobaoSubPurchaseOrder'
	    order.item_id
	   when 'TaobaoOrder'
	   	''
	   end
	 end 

	 def sku_properties
	   case order._type	
	   when 'TaobaoSubPurchaseOrder'
	    order.sku_properties
	   when 'TaobaoOrder'
	   	order.sku_properties_name  
	   end
	 end 

	 def auction_price
	   case order._type	
	   when 'TaobaoSubPurchaseOrder'
	    order.auction_price
	   when 'TaobaoOrder'
	   	order.price
	   end
	 end 

	 def buyer_payment
	   case order._type	
	   when 'TaobaoSubPurchaseOrder'
	    order.buyer_payment
	   when 'TaobaoOrder'
	    ''
	   end
	 end 

	 def distributor_payment
	   case order._type	
	   when 'TaobaoSubPurchaseOrder'
	    order.distributor_payment
	   when 'TaobaoOrder'
	    ''
	   end
	 end 

	 def item_outer_id
	   case order._type	
	   when 'TaobaoSubPurchaseOrder'
	    order.item_outer_id
	   when 'TaobaoOrder'
	    ''
	   end
	 end 

end  