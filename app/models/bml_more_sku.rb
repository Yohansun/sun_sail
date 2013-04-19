# -*- encoding : utf-8 -*-
class BmlMoreSku
	# def to_s
	# 	stock = Builder::XmlMarkup.new
	# 	stock.skus do
	# 		stock.sku do
	# 			stock.spuCode "TEST8782011122"
	# 			stock.Name "NokiaN73"
	# 			stock.desc ""
	# 			stock.combination do
	# 				stock.sonSku do
	# 					stock.spuCode "TEST8782011122"
	# 					stock.Name "NokiaN73"
	# 					stock.num 1
	# 				end
	# 				stock.sonSku do
	# 					stock.spuCode "TEST8782011132"
	# 					stock.Name "NokiaN74"
	# 					stock.num 1
	# 				end
	# 			end
	# 		end
	# 	end
	# 	stock.target!
	# end
	# #推送组合商品 SKU 同步信息至仓库
  # def self.more_sku_to_wms(bml_more_sku)
  #   client = Savon.client(wsdl: "http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
  #   # if Rails.env.production?
  #     response = client.call(:more_sku_to_wms, message:{CustomerId:"ALLYES", PWD:"BML33570",xml: bml_more_sku})
  #     response.body[:more_sku_to_wms_response][:out]
  #   # else
  #   #   p "stock operation not allowed out of production stage"
  #   # end
  # end
end