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
			stock.customerId $biaogan_customer_id
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
    return if checked_at.present?
    update_attributes(checked_at: Time.now)
    if account && account.settings.enable_module_third_party_stock != 1
      sync_stock
    end
  end

  def sync
    return if (checked_at.blank?  || sync_succeded_at.present? || (sync_at.present? && sync_failed_at.blank?) )
    update_attributes(sync_at: Time.now)
    ans_to_wms
  end

  def rollback
    if sync_succeded_at.present?
      cancel_asn_rx
    end
  end

	#推送入库通知单至仓库
  def ans_to_wms
    client = Savon.client(wsdl: $biaogan_client)
    response = client.call(:ans_to_wms, message:{CustomerId: $biaogan_customer_id, PWD: $biaogan_customer_password, xml: xml})
    result_xml = response.body[:ans_to_wms_response][:out]
    result = Hash.from_xml(result_xml).as_json
    if result['Response']['success'] == 'true'
      update_attributes(sync_succeded_at: Time.now)
      operation_logs.create(operated_at: Time.now, operation: '同步成功')
    else
      update_attributes(sync_failed_at: Time.now, failed_desc: result['Response']['desc'])
      operation_logs.create(operated_at: Time.now, operation: "同步失败,#{result['Response']['desc']}")
    end
  end

  #发送入库单取消信息至仓库
  def cancel_asn_rx
    client = Savon.client(wsdl: $biaogan_client)
    response = client.call(:cancel_asn_rx) do
      message CustomerId: $biaogan_customer_id, PWD: $biaogan_customer_password, AsnNo: tid
    end
    result_xml = response.body[:cancel_asn_rx_response][:out]
    result = Hash.from_xml(result_xml).as_json
    if result['Response']['success'] == 'true'
      update_attributes(cancel_succeded_at: Time.now)
      operation_logs.create(operated_at: Time.now, operation: '取消成功')
      restore_stock
    else
      update_attributes(cancel_failed_at: Time.now, failed_desc: result['Response']['desc'])
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
