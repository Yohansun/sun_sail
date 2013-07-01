# -*- encoding : utf-8 -*-
class StockApiController < ApplicationController
	include WashOut::SOAP

  skip_before_filter :verify_authenticity_token, :authenticate_user!

  soap_action "input_back", args: {login: :string, passwd: :string, xml: :string}, return: :string


  # client = Savon.client(wsdl: 'http://localhost:3000/stock_api/wsdl')
  # xml = "<ASNDetails><ASNs><ASNNo>0000191924</ASNNo><CustmorOrderNo>E120500073786</CustmorOrderNo><ExpectedArriveTime>2012-05-14 13:05:29</ExpectedArriveTime><Details><Detail><SkuCode>DB00124</SkuCode><ReceivedTime>2012-06-15 15:06:51</ReceivedTime><ExpectedQty>1</ExpectedQty><ReceivedQty>1</ReceivedQty><Lotatt01>null</Lotatt01><Lotatt02>null</Lotatt02><Lotatt03>null</Lotatt03><Lotatt04>null</Lotatt04><Lotatt05>null</Lotatt05><Lotatt06>HG</Lotatt06><Lotatt07>null</Lotatt07><Lotatt08>null</Lotatt08><Lotatt09>null</Lotatt09><Lotatt10>null</Lotatt10><Lotatt11>null</Lotatt11><Lotatt12>null</Lotatt12></Detail><Detail><SkuCode>DB00123</SkuCode><ReceivedTime>2012-06-15 15:06:51</ReceivedTime><ExpectedQty>1</ExpectedQty><ReceivedQty>1</ReceivedQty><Lotatt01>null</Lotatt01><Lotatt02>null</Lotatt02><Lotatt03>null</Lotatt03><Lotatt04>null</Lotatt04><Lotatt05>null</Lotatt05><Lotatt06>HG</Lotatt06><Lotatt07>null</Lotatt07><Lotatt08>null</Lotatt08><Lotatt09>null</Lotatt09><Lotatt10>null</Lotatt10><Lotatt11>null</Lotatt11><Lotatt12>null</Lotatt12></Detail></Details></ASNs></ASNDetails>"
  # response = client.call(:input_back, message:{login:$biaogan_customer_id, passwd:$biaogan_customer_password,xml: xml})
  # response.body[:input_back_response][:value]

  #入库订单反馈
  def input_back
  	if params[:login] == $biaogan_customer_id && params[:passwd] == $biaogan_customer_password
  		response = Hash.from_xml(params[:xml]).as_json
      asn_details = response['ASNDetails']
      if asn_details
        asns = asn_details['ASNs']
        custmor_order_no = asns['CustmorOrderNo']
        stock_in_bill = StockInBill.where(tid: custmor_order_no).first
        unless stock_in_bill
          render soap: "ORDER_NOT_FOUND"
          return
        end
        record = stock_in_bill.bml_input_backs.create(
          custmor_order_no: custmor_order_no,
          asnno: asns['ASNNo'],
          received_time: Time.try(:parse,asns['ExpectedArriveTime'])
        )
        details = asns['Details']['Detail']
        details = [] << details unless details.is_a?(Array)
        details.each do |detail|
          record.bml_sku_with_lotatts.create(
          sku_code: detail['SkuCode'],
          received_time: Time.try(:parse, detail['ReceivedTime']),
          expected_qty: detail['ExpectedQty'],
          received_qty: detail['ReceivedQty'],
          lotatt01: detail['lotatt01'],
          lotatt02: detail['lotatt02'],
          lotatt03: detail['lotatt03'],
          lotatt04: detail['lotatt04'],
          lotatt05: detail['lotatt05'],
          lotatt06: detail['lotatt06'],
          lotatt07: detail['lotatt07'],
          lotatt08: detail['lotatt08'],
          lotatt09: detail['lotatt09'],
          lotatt10: detail['lotatt10'],
          lotatt11: detail['lotatt11'],
          lotatt12: detail['lotatt12']
          )
        end
        if stock_in_bill.sync_stock
          stock_in_bill.update_attributes(confirm_stocked_at: Time.now, status: 'STOCKED')
          stock_in_bill.operation_logs.create(operated_at: Time.now, operation: '确认入库成功')
          render soap: "SUCCESS"
        else
          stock_in_bill.update_attributes(confirm_failed_at: Time.now)
          stock_in_bill.operation_logs.create(operated_at: Time.now, operation: '确认入库失败')
          render soap: "FAILED"
        end
      else
        render soap: "EMPTY_ASNDETAILS"
      end
  	else
    	render :soap => "AUTHENTICATION_FAILED"
    end
  end

  soap_action "output_back", args: {login: :string, passwd: :string, xml: :string},return: :string

  # client = Savon.client(wsdl: 'http://localhost:3000/stock_api/wsdl')
  # xml = "<outputBacks><outputBack><orderNo>204951780606387</orderNo><shipNo>运单号</shipNo><shipTime>发运时间</shipTime><carrierID>物流公司编号</carrierID><carrierName>物流公司中文名称</carrierName><customerId>客户编号</customerId><bgNo>对应仓库的id号</bgNo><weight>1.235</weight><send><sku><skuCode>WERFV</skuCode><skuNum>33</skuNum></sku><sku><skuCode>SDFFF</skuCode><skuNum>34</skuNum></sku></send></outputBack></outputBacks>"
  # response = client.call(:output_back, message:{login:$biaogan_customer_id, passwd:$biaogan_customer_password,xml: xml})
  # response.body[:output_back_response][:value]

  #出库订单反馈
  def output_back
  	if params[:login] == $biaogan_customer_id && params[:passwd] == $biaogan_customer_password
      response = Hash.from_xml(params[:xml]).as_json
      output_backs = response['outputBacks']
      if output_backs
        output_back = output_backs['outputBack']
        tid = output_back['orderNo']
        stock_out_bill = StockOutBill.where(tid: tid).first
        unless stock_out_bill
          render soap: "ORDER NOT FOUND"
          return
        end
        record = stock_out_bill.bml_output_backs.create(
          tid: tid,
          out_sid: output_back['shipNo'],
          delivered_at: Time.try(:parse, output_back['shipTime']),
          logistic_code: output_back['carrierID'],
          logictic_name: output_back['carrierName'],
          custom_id: output_back['customerId'],
          bml_stock_id: output_back['bgNo'],
          weight: output_back['weight']
        )
        trade = stock_out_bill.trade
        logistic = Logistic.find_by_code(output_back['carrierID'])
        trade.update_attributes(
          logistic_waybill: output_back['shipNo'],
          logistic_name: output_back['carrierName'],
          logistic_code: output_back['carrierID'],
          logistic_id: logistic.try(:id),
          status: 'STOCKED'
        )
        skus = output_back['send']['sku']
        skus = [] << skus unless skus.is_a?(Array)
        skus.each do |sku|
          sku = sku['skuCode']
          num = sku['numNum'].to_i
          record.bml_sku_with_nums.create(sku: sku, num: num)
        end
        if stock_out_bill.decrease_actual
          stock_out_bill.update_attributes(confirm_stocked_at: Time.now, status: 'STOCKED')
          stock_out_bill.operation_logs.create(operated_at: Time.now, operation: '确认出库成功')
          render soap: "SUCCESS"
        else
          stock_out_bill.update_attributes(confirm_failed_at: Time.now)
          stock_out_bill.operation_logs.create(operated_at: Time.now, operation: '确认出库失败')
          render soap: "FAILED"
        end
      else
        render soap: "EMPTY_OUTPUTBACKS"
      end
  	else
    	render soap: "AUTHENTICATION_FAILED"
    end
  end


  before_filter :dump_parameters
  def dump_parameters
    Rails.logger.debug params.inspect
  end
end