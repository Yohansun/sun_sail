# -*- encoding : utf-8 -*-

class BmlSkusPuller
  class << self   
  	def sync_local_from_bml(account_id = 2)
  		return unless account
		  seller = account.sellers.first
		  return unless seller
		  local_stocks = seller.stock_products 
		  return unless local_stocks
		  local_stocks.each do |local_stock|
		  	product = local_stock.product
		   	next unless product
		   	outer_id = product.outer_id
		   	response_str = Bml.stock_query_by_sku(sku)
		   	stock_query = OpenStruct.new(Hash.from_xml(response_str).as_json).StockQuery
		   	if stock_query
		   		bml_stock = stock_query.fetch('Stock')
		   		qty = bml_stock.fetch('Qty')
		   		qty_allocated = bml_stock.fetch('QtyAllocated') 
		   		qty_on_hold = bml_stock.fetch('QtyOnHold')
		   		
		   		actual = local_stock.actual
		   		activity = local_stock.activity

		   		if qty == actual && qty_allocated == activity 
		   		else
		   			"miss assigned occured! sku #{sku}"
		   			p "Qty #{qty} QtyAllocated #{qty_allocated} QtyOnHold #{qty_on_hold}"
		   			p "actual #{actual} activity #{activity}"
		   		end	
		   	else
		   		p "outer_id #{outer_id} not found in bml"
		   	end	
		  end	
  	end	
  end
end
