# -*- encoding:utf-8 -*-
class StockInBill < StockBill
	include Mongoid::Document
  include MagicEnum
	embeds_many :bml_input_backs

  PUBLIC_STOCK_TYPE = PUBLIC_IN_STOCK_TYPE
  PRIVATE_STOCK_TYPE = PRIVATE_IN_STOCK_TYPE
  enum_attr :stock_type,IN_STOCK_TYPE
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
						stock.spuCode product.outer_id.try(:strip)
						stock.itemName product.title.try(:strip)
						stock.itemCount product.number
						stock.itemValue product.total_price
						stock.remark ""
					end
				end
			end
		end
		stock.target!
	end

  def gqs_xml
    stock = ::Builder::XmlMarkup.new
    stock.DATA do
      stock.RECEIPT do
        stock.HEADER do
          stock.RECEIPTID tid                                                   #YH2013030001  网站系统生成的订单编号 必填  VARCHAR2  30
          stock.RECEIPTDATE stocked_at.try(:strftime, "%Y-%m-%d %H:%M")         #2013-03-27 16:00  订单创建日期  必填  DATE
          stock.RECEIPTTYPE 'STD'                                               #订单类型,淘宝订单,分销,退货
          stock.POID tid                                                        #采购单号
          stock.TOTALPIECESQTY bill_products_mumber
        end
        bill_products.each do |product|
          stock.DETAIL do
            stock.ITEMID product.outer_id.try(:strip)
            stock.STATUSID 1
            stock.DESCR product.title.try(:strip)
            stock.QTYRECEIVED product.number
            stock.QTY product.number
            stock.UNITPRICE  product.price
          end
        end
      end
    end
    stock.target!
  end

  def check
    return false if not can_do_check?
    do_check
    sync_stock if account && account.settings.enable_module_third_party_stock != 1
    initial_stock if stock_type == "IINITIAL"
  end

  def type_name
    "入库单"
  end
  
  def confirm_sync
    ans_to_wms_worker
  end
  
  def confirm_stock
    if can_do_stock?
      do_stock && sync_stock && operation_logs.create(operated_at: Time.now, operation: '确认入库成功')
    end
  end

  def lock!(user)
    return "不能再次锁定!" if self.operation_locked?
    notice = "同步至仓库出库单需要先撤销同步后才能锁定"
    return notice if self.status == "SYNCKED"
    return "已经同步出库单不能锁定，请先撤销同步" if !["CHECKED","CREATED","CANCELD_OK"].include?(self.status)  #"只能操作状态为: 1.已审核，待同步. 2.待审核. 3.撤销同步成功"
    self.operation = "locked"
    self.operation_time = Time.now
    build_log(user,"锁定")

    self.save(validate: false)
  end

  def unlock!(user)
    return "只能操作的状态为: 已锁定." if !self.operation_locked?
    self.operation = "activated"
    self.operation_time = Time.now
    build_log(user,"激活")

    self.save(validate: false)
  end

  def sync
    if can_do_syncking?
      do_syncking
      ans_to_wms if account.settings.enable_module_third_party_stock == 1
    end
  end

  def rollback
    do_canceling && cancel_asn_rx if can_do_canceling?
  end

  def ans_to_wms
    BiaoganPusher.perform_async(self._id, "ans_to_wms_worker")
  end

  def cancel_asn_rx
    BiaoganPusher.perform_async(self._id, "cancel_asn_rx_worker")
  end

	#推送入库通知单至仓库
  def ans_to_wms_worker
    if account.settings.third_party_wms == "biaogan"
      result_xml = Bml.ans_to_wms(account, xml)
    elsif account.settings.third_party_wms == "gqs"
      result_xml = Gqs.receipt_add(account, gqs_xml)
    elsif account.settings.enable_module_third_party_stock != 1
      return do_syncked && operation_logs.create(operated_at: Time.now, operation: '同步成功')
    end
    result = Hash.from_xml(result_xml).as_json

    #BML
    if result['Response']
      if result['Response']['success'] == 'true'
        do_syncked
        operation_logs.create(operated_at: Time.now, operation: '同步成功')
      else
        self.failed_desc = result['Response']['desc']
        do_synck_fail
        operation_logs.create(operated_at: Time.now, operation: "同步失败,#{result['Response']['desc']}")
      end
    end

    #GQS
    if result['DATA']
      if result['DATA']['RET_CODE'] == 'SUCC'
        do_syncked
        operation_logs.create(operated_at: Time.now, operation: '同步成功')
      else
        self.failed_desc = result['DATA']['RET_MESSAGE']
        do_synck_fail
        operation_logs.create(operated_at: Time.now, operation: "同步失败,#{result['DATA']['RET_MESSAGE']}")
      end
    end

  end

  #发送入库单取消信息至仓库
  def cancel_asn_rx_worker
    if account.settings.third_party_wms == "biaogan"
      result_xml = Bml.cancel_asn_rx(account, tid)
    elsif account.settings.third_party_wms == "gqs"
      result_xml = Gqs.cancel_order(account, orderid: tid,notes: '客户取消订单',opttype: 'OrderCance',opttime: Time.now.to_s(:db),method: 'OrderCance',_prefix: "receipt")
    elsif account.settings.enable_module_third_party_stock != 1
      return do_cancel_ok && operation_logs.create(operated_at: Time.now, operation: '取消成功')
    end
    result = Hash.from_xml(result_xml).as_json

    #BML
    if result['Response']
      if result['Response']['success'] == 'true'
        do_cancel_ok
        operation_logs.create(operated_at: Time.now, operation: '取消成功')
      else
        self.failed_desc = result['Response']['desc']
        do_cancel_fail
        operation_logs.create(operated_at: Time.now, operation: "取消失败,#{result['Response']['desc']}")
      end
    end

    #GQS
    if result['DATA']
      if result['DATA']['RET_CODE'] == 'SUCC'
        do_cancel_ok
        operation_logs.create(operated_at: Time.now, operation: '取消成功')
      else
        self.failed_desc = result['DATA']['RET_MESSAGE']
        do_cancel_fail
        operation_logs.create(operated_at: Time.now, operation: "取消失败,#{result['DATA']['RET_MESSAGE']}")
      end
    end
  end

  def sync_stock #确认入库
    bill_products.each do |stock_in|
      stock_product = StockProduct.find_by_id(stock_in.stock_product_id)
      if stock_product
        update_attrs = {:actual => stock_product.actual + stock_in.number, :activity => stock_product.activity + stock_in.number,audit_comment: "入库单ID:#{self.id}"}
        stock_product.update_attributes(update_attrs)
        true
      else
        # DO SOME ERROR NOTIFICATION
        false
      end
    end
  end

  def initial_stock
    sync_stock if account && account.settings.enable_module_third_party_stock == 1
    do_stock
    StockCsvFile.find_by_stock_in_bill_id(self.id.to_s).update_attributes(used: true)
  end
end
