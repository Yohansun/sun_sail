# -*- encoding:utf-8 -*-
class StockInBill < StockBill 
	include Mongoid::Document
	embeds_many :bml_input_backs
	def xml
		stock = ::Builder::XmlMarkup.new
		stock.RequestPurchaseInfo do 
			stock.warehouseid "BML_KSWH"
			stock.type stock_type 
			stock.orderCode tid
			stock.customerId "ALLYES"
			stock.ZDRQ created_at.try(:strftime, "%Y-%m-%d %H:%M")
			stock.DHRQ stocked_at.try(:strftime, "%Y-%m-%d %H:%M")
			stock.ZDR  operator_name 
			stock.BZ  remark 		
			stock.products do 
				bill_products.each do |product|
					stock.productInfo do
						stock.spuCode product.outer_id
						stock.itemName product.title
						stock.itemCount product.number
						stock.itemValue product.total_price
						stock.remark ""
					end
				end
			end	
		end
		stock.target!
	end

	#推送入库通知单至仓库
  def ans_to_wms
    client = Savon.client(wsdl: "http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    # if Rails.env.production?
      response = client.call(:ans_to_wms, message:{CustomerId:"ALLYES", PWD:"BML33570", xml: xml})
      result_xml = response.body[:ans_to_wms_response][:out]
      result = Hash.from_xml(result_xml).as_json
      if result['response']['success']
      	update_attributes(sync_succeded_at: Time.now)
      else
      	update_attributes(sync_failed_at: Time.now, failed_desc: result['response']['success']['desc'])
      end
    # else
    #   p "stock operation not allowed out of production stage"
    # end
  end  

  #发送入库单取消信息至仓库
  def cancel_asn_rx
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    # if Rails.env.production?
      response = client.call(:cancel_asn_rx) do
        message CustomerId:"ALLYES", PWD:"BML33570", AsnNo: tid 
      end
      result_xml = response.body[:cancel_asn_rx_response][:out]
      result = Hash.from_xml(result_xml).as_json
      if result['response']['success']
      	update_attributes(cancel_succeded_at: Time.now)
      	restore_stock
      else
      	update_attributes(cancel_failed_at: Time.now, failed_desc: result['response']['success']['desc'])
      end
    # else
    #   p "stock operation not allowed out of production stage"
    # end
  end  

  def restore_stock
  	true
  end 

  def sync_stock
  	true
  end 
end
