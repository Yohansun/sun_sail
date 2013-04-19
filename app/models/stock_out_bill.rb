# -*- encoding:utf-8 -*-
class StockOutBill < StockBill
	include Mongoid::Document
	belongs_to :trade
	embeds_many :bml_output_backs
	def xml
		stock = ::Builder::XmlMarkup.new
		stock.RequestOrderList do 
			stock.RequestOrderInfo do
				stock.warehouseid "BML_KSWH"
				stock.customerId "ALLYES"
				stock.orderCode tid 
				stock.systemId tid 
				stock.orderType stock_type
				stock.shipping logistic_code
				stock.issuePartyId "" 
				stock.issuePartyName "" 
				stock.customerName op_name
				stock.payment "" 
				stock.orderTime ""
				stock.website ""
				stock.freight trade.post_fee 
				stock.serviceCharge 0.00
				stock.payTime ""
				stock.isCashsale ""
				stock.priority ""
				stock.expectedTime "" 
				stock.requiredTime ""
				stock.name op_name
				stock.postcode op_zip
				stock.phone op_phone
				stock.mobile op_mobile
				stock.prov op_state
				stock.city op_city
				stock.district op_district
				stock.address op_address 
				stock.itemsValue bill_products_price
				stock.items do
					bill_products.each do |product|
						stock.item do
							stock.spuCode product.outer_id
							stock.itemName product.title
							stock.itemCount product.number
							stock.itemValue product.total_price
						end
					end	
				end
				stock.remark remark      
			end
		end	
		stock.target!
	end	

	#推送出库单至仓库
  def so_to_wms
    client = Savon.client(wsdl: "http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    # if Rails.env.production?
      response = client.call(:so_to_wms, message:{CustomerId:"ALLYES", PWD:"BML33570",xml: xml})
      result_xml = response.body[:so_to_wms_response][:out]
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

  #发送订单取消信息至仓库
  def cancel_order_rx
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    # if Rails.env.production?
      response = client.call(:cancel_order_rx) do
        message CustomerId:"ALLYES", PWD:"BML33570", AsnNo: tid 
      end
      result_xml =response.body[:cancel_order_rx_response][:out]
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
