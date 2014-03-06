# -*- encoding : utf-8 -*-
class StockApiController < ApplicationController
	include WashOut::SOAP

  skip_before_filter :verify_authenticity_token, :authenticate_user!

  soap_action "input_back", args: {login: :string, passwd: :string, xml: :string}, return: :string


  # client = Savon.client(wsdl: 'http://localhost:3000/stock_api/wsdl')
  # xml = "<ASNDetails><ASNs><ASNNo>0000191924</ASNNo><CustmorOrderNo>E120500073786</CustmorOrderNo><ExpectedArriveTime>2012-05-14 13:05:29</ExpectedArriveTime><Details><Detail><SkuCode>DB00124</SkuCode><ReceivedTime>2012-06-15 15:06:51</ReceivedTime><ExpectedQty>1</ExpectedQty><ReceivedQty>1</ReceivedQty><Lotatt01>null</Lotatt01><Lotatt02>null</Lotatt02><Lotatt03>null</Lotatt03><Lotatt04>null</Lotatt04><Lotatt05>null</Lotatt05><Lotatt06>HG</Lotatt06><Lotatt07>null</Lotatt07><Lotatt08>null</Lotatt08><Lotatt09>null</Lotatt09><Lotatt10>null</Lotatt10><Lotatt11>null</Lotatt11><Lotatt12>null</Lotatt12></Detail><Detail><SkuCode>DB00123</SkuCode><ReceivedTime>2012-06-15 15:06:51</ReceivedTime><ExpectedQty>1</ExpectedQty><ReceivedQty>1</ReceivedQty><Lotatt01>null</Lotatt01><Lotatt02>null</Lotatt02><Lotatt03>null</Lotatt03><Lotatt04>null</Lotatt04><Lotatt05>null</Lotatt05><Lotatt06>HG</Lotatt06><Lotatt07>null</Lotatt07><Lotatt08>null</Lotatt08><Lotatt09>null</Lotatt09><Lotatt10>null</Lotatt10><Lotatt11>null</Lotatt11><Lotatt12>null</Lotatt12></Detail></Details></ASNs></ASNDetails>"
  # response = client.call(:input_back, message:{login: account.settings.stock_login, passwd: account.settings.stock_passwd,xml: xml})
  # response.body[:input_back_response][:value]

  #入库订单反馈
  def input_back
    response = Hash.from_xml(params[:xml]).as_json
    asn_details = response['ASNDetails']
    if asn_details
      asns = asn_details['ASNs']
      custmor_order_no = asns['CustmorOrderNo']
      unless StockInBill.where(tid: custmor_order_no).exists?
        render soap: "ORDER NOT FOUND"
        return
      end
      stock_in_bill = StockInBill.where(tid: custmor_order_no, :status.in => ['SYNCKED',"CANCELD_FAILED"]).first
      unless stock_in_bill
        render soap: "ORDER STATUS UNCHANGEABLE"
        return
      end

      account = stock_in_bill.account

      if params[:login] == account.settings.stock_login && params[:passwd] ==  account.settings.stock_passwd
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
        if stock_in_bill.status == "STOCKED"
          render soap: "SUCCESS"
        elsif stock_in_bill.sync_stock
          stock_in_bill.do_stock
          recording(stock_in_bill.operation_logs,{operation: '确认入库成功',text: response})
          render soap: "SUCCESS"
        else
          stock_in_bill.update_attributes(confirm_failed_at: Time.now)
          recording(stock_in_bill.operation_logs,{operation: '确认入库失败',text: response})
          render soap: "FAILED"
        end
      else
        render :soap => "AUTHENTICATION_FAILED"
      end
    else
      render soap: "EMPTY_ASNDETAILS"
    end
  end

  soap_action "output_back", args: {login: :string, passwd: :string, xml: :string},return: :string

  # client = Savon.client(wsdl: 'http://localhost:3000/stock_api/wsdl')
  # xml = "<outputBacks><outputBack><orderNo>204951780606387</orderNo><shipNo>运单号</shipNo><shipTime>发运时间</shipTime><carrierID>物流公司编号</carrierID><carrierName>物流公司中文名称</carrierName><customerId>客户编号</customerId><bgNo>对应仓库的id号</bgNo><weight>1.235</weight><send><sku><skuCode>WERFV</skuCode><skuNum>33</skuNum></sku><sku><skuCode>SDFFF</skuCode><skuNum>34</skuNum></sku></send></outputBack></outputBacks>"
  # response = client.call(:output_back, message:{login: account.settings.stock_login, passwd: account.settings.stock_passwd,xml: xml})
  # response.body[:output_back_response][:value]

  #出库订单反馈
  def output_back
    response = Hash.from_xml(params[:xml]).as_json
    output_backs = response['outputBacks']
    if output_backs
      output_back = output_backs['outputBack']
      tid = output_back['orderNo']
      unless StockOutBill.where(tid: tid).exists?
        render soap: "ORDER NOT FOUND"
        return
      end
      stock_out_bill = StockOutBill.where(tid: tid, :status.in => ['SYNCKED',"CANCELD_FAILED"]).first
      unless stock_out_bill
        render soap: "ORDER STATUS UNCHANGEABLE"
        return
      end
      account = stock_out_bill.account
      if params[:login] ==  account.settings.stock_login && params[:passwd] ==  account.settings.stock_passwd
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

        # In case of handmade stock_out_bill
        if trade
          is_first_set = trade.logistic_waybill.blank?
          logistic = Logistic.find_by_code(output_back['carrierID'])
          trade.update_attributes(
            logistic_waybill: output_back['shipNo'],
            logistic_name: output_back['carrierName'],
            logistic_code: output_back['carrierID'],
            logistic_id: logistic.try(:id),
            service_logistic_id: trade.get_third_party_logistic_id(logistic.try(:id))
          )

          if account && account.settings && account.settings.auto_settings
            auto_settings = account.settings.auto_settings
            if auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "has_logistic_waybill_trade" && is_first_set
              trade.auto_deliver!
            end
          end
        end

        skus = output_back['send']['sku']
        skus = [] << skus unless skus.is_a?(Array)
        skus.each do |sku|
          sku = sku['skuCode']
          num = sku['numNum'].to_i
          record.bml_sku_with_nums.create(sku: sku, num: num)
        end
        if stock_out_bill.status == "STOCKED"
          render soap: "SUCCESS"
        elsif stock_out_bill.decrease_actual
          stock_out_bill.do_stock
          recording(stock_out_bill.operation_logs,{operation: '确认出库成功',text: response})
          render soap: "SUCCESS"
        else
          stock_out_bill.update_attributes(confirm_failed_at: Time.now)
          recording(stock_out_bill.operation_logs,{operation: '确认出库失败',text: response})
          render soap: "FAILED"
        end
      else
        render soap: "AUTHENTICATION_FAILED"
      end
    else
      render soap: "EMPTY_OUTPUTBACKS"
    end
  end

  soap_action "update_trade_stauts", args: {login: :string, passwd: :string, xml: :string}, return: :string

  # client = Savon.client(wsdl: 'http://localhost:3000/stock_api/wsdl')
  # xml = "<outputBacks><outputBack><orderNo>204951780606387</orderNo><shipNo>运单号</shipNo><shipTime>发运时间</shipTime><carrierID>物流公司编号</carrierID><carrierName>物流公司中文名称</carrierName><customerId>客户编号</customerId><bgNo>对应仓库的id号</bgNo><weight>1.235</weight><send><sku><skuCode>WERFV</skuCode><skuNum>33</skuNum></sku><sku><skuCode>SDFFF</skuCode><skuNum>34</skuNum></sku></send></outputBack></outputBacks>"
  # response = client.call(:update_trade_stauts, message:{login: account.settings.stock_login, passwd: account.settings.stock_passwd,xml: xml})
  # response.body[:update_trade_stauts_response][:value]

  def update_trade_stauts
    response = Hash.from_xml(params[:xml]).as_json
    data = response['DATA']
    if data
      order = data['ORDER']
      tid = order['ORDERID']
      unless StockBill.where(tid: tid).exists?
        render soap: "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>ORDER_NOT_FOUND</RET_MESSAGE></DATA>"
        return
      end
      stock_bill = StockBill.where(tid: tid, :status.ne => 'CLOSED').first
      unless stock_bill
        render soap: "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>ORDER_STATUS_UNCHANGEABLE</RET_MESSAGE></DATA>"
        return
      end
      account = stock_bill.account
      if params[:login] ==  account.settings.stock_login && params[:passwd] ==  account.settings.stock_passwd
        trade = stock_bill.trade
        if trade
          if order['OPTTYPE'] == 'OrderShip'
            is_first_set = trade.logistic_waybill.blank?
            logistic = Logistic.find_by_code(order['EXPRESSCODE'])
            trade.update_attributes!(logistic_waybill: order['SHIPMENTID'],logistic_name: logistic.try(:name),logistic_code: order['EXPRESSCODE'],logistic_id: logistic.try(:id),service_logistic_id: trade.get_third_party_logistic_id(logistic.try(:id)))

            if account && account.settings && account.settings.auto_settings
              auto_settings = account.settings.auto_settings
              if auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "has_logistic_waybill_trade" && is_first_set
                trade.auto_deliver!
              end
            end
          elsif order['OPTTYPE'] == 'OrderSign'
            recording(stock_bill.operation_logs,{operation: '签收',text: response})
          elsif order['OPTTYPE'] == 'OrderRefuse'
            recording(stock_bill.operation_logs,{operation: '拒收',text: response})
          end
        end

        if order['OPTTYPE'] == 'OrderShip'
          stock_bill.do_stock
          recording(stock_bill.operation_logs,{operation: '确认成功',text: response})
        elsif order['OPTTYPE'] == 'OrderSign'
          recording(stock_bill.operation_logs,{operation: '签收',text: response})
        elsif order['OPTTYPE'] == 'OrderRefuse'
          recording(stock_bill.operation_logs,{operation: '拒收',text: response})
        end
        render soap: "<DATA><RET_CODE>SUCC</RET_CODE><RET_MESSAGE>OK</RET_MESSAGE></DATA>"
      else
        render soap: "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>AUTHENTICATION_FAILED</RET_MESSAGE></DATA>"
      end
    else
      render soap: "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>EMPTY_XML</RET_MESSAGE></DATA>"
    end
  end


  before_filter :dump_parameters
  def dump_parameters
    Rails.logger.debug params.inspect
  end

  private
  def recording(record,options)
    record.create(options)
  end
end