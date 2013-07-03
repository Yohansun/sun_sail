# -*- encoding:utf-8 -*-
class StockOutBill < StockBill
  include Mongoid::Document
  include MagicEnum
  belongs_to :trade
  embeds_many :bml_output_backs

  enum_attr :stock_type, StockBill::OUT_STOCK_TYPE
  validates_inclusion_of :stock_type, :in => STOCK_TYPE_VALUES

  def xml
    stock = ::Builder::XmlMarkup.new
    stock.RequestOrderList do
      stock.RequestOrderInfo do
        stock.warehouseid "BML_KSWH"
        stock.customerId $biaogan_customer_id
        stock.orderCode tid
        stock.systemId tid
        stock.orderType stock_typs
        stock.shipping logistic_code
        stock.issuePartyId ""
        stock.issuePartyName ""
        stock.customerName op_name
        stock.payment ""
        stock.orderTime ""
        stock.website website || "个人"
        stock.freight trade.try(:post_fee)
        stock.serviceCharge 0.00
        stock.payTime ""
        stock.isCashsale is_cash_sale || "需要开票"
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

  def check
    return unless status == "CREATED"
    update_attributes(checked_at: Time.now, status: "CHECKED")
    if account && account.settings.enable_module_third_party_stock != 1
      sync_stock
    end
  end

  def sync
    return unless ['SYNCK_FAILED','CHECKED','CANCELD_OK'].include?(status)
    update_attributes(sync_at: Time.now, status: "SYNCKED")
    so_to_wms
  end

  def rollback
    return unless status == "SYNCKED"
    update_attributes(canceled_at: Time.now, status: "CANCELING")
    cancel_order_rx
  end

  #推送出库单至仓库
  def so_to_wms
    BiaoganPusher.perform_async(self._id, "so_to_wms_worker")
  end

  def cancel_order_rx
    BiaoganPusher.perform_async(self._id, "cancel_order_rx_worker")
  end

  def so_to_wms_worker
    if ((trade && trade.status == "WAIT_SELLER_SEND_GOODS") || (!trade))
      client = Savon.client(wsdl: $biaogan_client)
      response = client.call(:so_to_wms, message:{CustomerId: $biaogan_customer_id, PWD: $biaogan_customer_password,xml: xml})
      result_xml = response.body[:so_to_wms_response][:out]
      result = Hash.from_xml(result_xml).as_json
      if result['Response']['success'] == 'true'
        update_attributes(sync_succeded_at: Time.now, status: "SYNCKED")
        operation_logs.create(operated_at: Time.now, operation: '同步成功')
      else
        update_attributes(sync_failed_at: Time.now, failed_desc: result['Response']['desc'], status: "SYNCK_FAILED")
        operation_logs.create(operated_at: Time.now, operation: "同步失败,#{result['Response']['desc']}")
      end
    end
  end

  #发送订单取消信息至仓库
  def cancel_order_rx_worker
    client = Savon.client(wsdl: $biaogan_client)
    response = client.call(:cancel_order_rx) do
      message CustomerId: $biaogan_customer_id, PWD: $biaogan_customer_password, AsnNo: tid
    end
    result_xml = response.body[:cancel_order_rx_response][:out]
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

  def sync_stock #确认出库
    bill_products.each do |stock_out|
      sku_id = stock_out.try(:sku_id)
      stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
      if stock_product
        stock_product.update_attributes(actual: stock_product.actual - stock_out.number, activity: stock_product.activity - stock_out.number)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end

  def restore_stock #恢复仓库的可用库存和实际库存
    bill_products.each do |stock_out|
      stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
      if stock_product
        stock_product.update_attributes(actual: stock_product.actual + stock_out.number, activity: stock_product.activity + stock_out.number)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end

  def increase_activity #恢复仓库的可用库存
    bill_products.each do |stock_out|
      stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
      if stock_product
        stock_product.update_attributes(activity: stock_product.activity - stock_out.number)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end

  def decrease_activity #减去仓库的可用库存
    bill_products.each do |stock_out|
      stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
      if stock_product
        stock_product.update_attributes(activity: stock_product.activity - stock_out.number)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end

  def decrease_actual #减去仓库的实际库存
    bill_products.each do |stock_out|
      stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
      if stock_product
        stock_product.update_attributes(actual: stock_product.actual - stock_out.number)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end

end