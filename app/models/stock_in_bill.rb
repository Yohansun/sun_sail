# -*- encoding:utf-8 -*-
class StockInBill < StockBill
	include Mongoid::Document
  include MagicEnum
	embeds_many :bml_input_backs

  enum_attr :stock_type,StockBill::IN_STOCK_TYPE
  validates_inclusion_of :stock_type, :in => STOCK_TYPE_VALUES

	def xml
		stock = ::Builder::XmlMarkup.new
		stock.RequestPurchaseInfo do
			stock.warehouseid "BML_KSWH"
			stock.type stock_typs
			stock.orderCode tid
			stock.customerId account.settings.biaogan_customer_id
			stock.ZDRQ created_at.try(:strftime, "%Y-%m-%d %H:%M")
			stock.DHRQ stocked_at.try(:strftime, "%Y-%m-%d %H:%M")
			stock.ZDR op_name
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


  def check
    return if status != "CREATED" || self.operation_locked?
    update_attributes(checked_at: Time.now, status: "CHECKED")
    if account && account.settings.enable_module_third_party_stock != 1
      sync_stock
    end
  end

  def sync
    return unless ['SYNCK_FAILED','CHECKED','CANCELD_OK'].include?(status)
    update_attributes(sync_at: Time.now, status: "SYNCKING")
    ans_to_wms
  end

  def rollback
    return if status != "SYNCKED" || self.operation_locked?
    update_attributes(canceled_at: Time.now, status: "CANCELING")
    cancel_asn_rx
  end

  def ans_to_wms
    BiaoganPusher.perform_async(self._id, "ans_to_wms_worker")
  end

  def cancel_asn_rx
    BiaoganPusher.perform_async(self._id, "cancel_asn_rx_worker")
  end

	#推送入库通知单至仓库
  def ans_to_wms_worker
    client = Savon.client(wsdl: account.settings.biaogan_client)
    response = client.call(:ans_to_wms, message:{CustomerId: account.settings.biaogan_customer_id, PWD: account.settings.biaogan_customer_password, xml: xml})
    result_xml = response.body[:ans_to_wms_response][:out]
    result = Hash.from_xml(result_xml).as_json
    if result['Response']['success'] == 'true'
      update_attributes(sync_succeded_at: Time.now, status: "SYNCKED")
      operation_logs.create(operated_at: Time.now, operation: '同步成功')
    else
      update_attributes(sync_failed_at: Time.now, failed_desc: result['Response']['desc'], status: "SYNCK_FAILED")
      operation_logs.create(operated_at: Time.now, operation: "同步失败,#{result['Response']['desc']}")
    end
  end

  #发送入库单取消信息至仓库
  def cancel_asn_rx_worker
    client = Savon.client(wsdl: account.settings.biaogan_client)
    response = client.call(:cancel_asn_rx) do
      message CustomerId: account.settings.biaogan_customer_id, PWD: account.settings.biaogan_customer_password, AsnNo: tid
    end
    result_xml = response.body[:cancel_asn_rx_response][:out]
    result = Hash.from_xml(result_xml).as_json
    if result['Response']['success'] == 'true'
      update_attributes(cancel_succeded_at: Time.now, status: "CANCELD_OK")
      operation_logs.create(operated_at: Time.now, operation: '取消成功')
      restore_stock
    else
      update_attributes(cancel_failed_at: Time.now, failed_desc: result['Response']['desc'], status: "CANCELD_FAILED")
      operation_logs.create(operated_at: Time.now, operation: "取消失败,#{result['Response']['desc']}")
    end
  end

  def sync_stock #确认入库
    bill_products.each do |stock_in|
      stock_product = StockProduct.find_by_id(stock_in.stock_product_id)
      if stock_product
        stock_product.update_attributes(actual: stock_product.actual + stock_in.number, activity:stock_product. activity + stock_in.number)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end

  def restore_stock #恢复仓库的可用库存和实际库存
    bill_products.each do |stock_in|
      stock_product = StockProduct.find_by_id(stock_in.stock_product_id)
      if stock_product
        stock_product.update_attributes(actual: stock_product.actual - stock_in.number, activity: stock_product.activity - stock_in.number)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end
end
