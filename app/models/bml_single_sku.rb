# -*- encoding : utf-8 -*-
class BmlSingleSku
	def self.xml(product)
		stock = Builder::XmlMarkup.new
		stock.skus do
			stock.sku do
				stock.skucode product.outer_id
				stock.name product.name
				stock.desc ""
				stock.ALTERNATESKU1 ""
				stock.ALTERNATESKU2 ""
			end
		end
		stock.target!
	end	
	
	#推送 SKU 同步信息至仓库
  def self.single_sku_to_wms(product)
  	xml = BmlSingleSku.xml(product)
    client = Savon.client(wsdl: "http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    # if Rails.env.production?
      response = client.call(:single_sku_to_wms, message:{CustomerId:"ALLYES", PWD:"BML33570",xml:xml})
      response.body[:single_sku_to_wms_response][:out]
    # else
    #   p "stock operation not allowed out of production stage"
    # end
  end
  def self.all_sku_to_wms(account)
		account.products.find_each do |product|
			BmlSingleSku.single_sku_to_wms(product)
		end	
	end	
end