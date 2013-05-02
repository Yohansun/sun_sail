# -*- encoding : utf-8 -*-
require "savon"
class Bml 
  def self.search_order_status(tid)
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
      response = client.call(:search_order_status) do
        message CustomerId:"ALLYES", PWD:"BML33570", orderId: tid 
      end
      response.body[:search_order_status_response][:out]
  end
  
  #查询当前库存(按 SKU)
  def self.stock_query_by_sku(sku)
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:stock_query_by_sku) do
      message CustomerId:"ALLYES", PWD:"BML33570", SKU: sku 
    end
    response.body[:stock_query_by_sku_response][:out]
  end 

  #查询当天订单明细
  def self.order_detail_query_today
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:order_detail_query_today) do
      message CustomerId:"ALLYES", PWD:"BML33570" 
    end
    response.body[:order_detail_query_today_response][:out]
  end

  #查询前一天订单明细
  def self.order_detail_query_yesterday
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:order_detail_query_yesterday) do
      message CustomerId:"ALLYES", PWD:"BML33570" 
    end
    response.body[:order_detail_query_yesterday_response][:out]
  end

  #根据客户订单号查询入库明细
  def self.order_detail_query_by_id(orderId)
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:order_detail_query_by_id) do
      message CustomerId:"ALLYES", PWD:"BML33570", OrderId: orderId 
    end
    response.body[:order_detail_query_by_id_response][:out]
  end


   #查询当天入库单明细
  def self.notice_of_arrival_query_today
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:notice_of_arrival_query_today) do
      message CustomerId:"ALLYES", PWD:"BML33570" 
    end
    response.body[:notice_of_arrival_query_today_response][:out]
  end

  #查询前一天入库单明细
  def self.notice_of_arrival_query_yesterday
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:notice_of_arrival_query_yesterday) do
      message CustomerId:"ALLYES", PWD:"BML33570" 
    end
    response.body[:notice_of_arrival_query_yesterday_response][:out]
  end

  #按照入库单号查询入库单
  def self.notice_of_arrival_query_by_id(orderId)
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:notice_of_arrival_query_by_id) do
      message CustomerId:"ALLYES", PWD:"BML33570", OrderId: orderId 
    end
    response.body[:notice_of_arrival_query_by_id_response][:out]
  end

  #查询订单发运明细
  def self.shipment_info_query_by_order_id(orderId)
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:shipment_info_query_by_order_id) do
      message CustomerId:"ALLYES", PWD:"BML33570", OrderId: orderId 
    end
    response.body[:shipment_info_query_by_order_id_response][:out]
  end

   #查询订单某一天的发运明细(只能查询一周内的发运明细)
  def self.shipment_info_query_by_date(date)
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:shipment_info_query_by_date) do
      message CustomerId:"ALLYES", PWD:"BML33570", Date:date 
    end
    response.body[:shipment_info_query_by_date_response][:out]
  end

  #查询当天订单汇总
  def self.order_collection_today
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:order_collection_today) do
      message CustomerId:"ALLYES", PWD:"BML33570" 
    end
    response.body[:order_collection_today_response][:out]
  end


  #查询前一天订单汇总
  def self.order_collection_yesterday
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:order_collection_yesterday) do
      message CustomerId:"ALLYES", PWD:"BML33570" 
    end
    response.body[:order_collection_yesterday_response][:out]
  end


  #查询当前库存  
  def self.stock_query
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    response = client.call(:stock_query) do
      message CustomerId:"ALLYES", PWD:"BML33570" 
    end
    response.body[:stock_query_response][:out]
  end

  def self.operations
    client = Savon.client(wsdl:"http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl")
    client.operations
  end  
    
end