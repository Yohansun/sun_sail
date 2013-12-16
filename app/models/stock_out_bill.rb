# -*- encoding:utf-8 -*-
class StockOutBill < StockBill
  include Mongoid::Document
  include MagicEnum
  embeds_many :bml_output_backs

  PUBLIC_STOCK_TYPE  = PUBLIC_OUT_STOCK_TYPE
  PRIVATE_STOCK_TYPE = PRIVATE_OUT_STOCK_TYPE
  enum_attr :stock_type, OUT_STOCK_TYPE
  validates_inclusion_of :stock_type, :in => STOCK_TYPE_VALUES

  def xml
    decorated_trade = TradeDecorator.decorate(trade)
    stock = ::Builder::XmlMarkup.new
    stock.RequestOrderList do
      stock.RequestOrderInfo do
        stock.warehouseid "BML_KSWH"
        stock.customerId account.settings.biaogan_customer_id
        stock.orderCode tid
        stock.systemId tid
        stock.orderType stock_typs
        stock.shipping logistic_code
        stock.issuePartyId ""
        stock.issuePartyName ""
        stock.customerName op_name
        stock.payment ""
        stock.orderTime ""
        stock.website outer_website
        stock.freight (decorated_trade.present? ? decorated_trade.try(:post_fee) : 0.0)
        stock.serviceCharge 0.00
        stock.payTime ""
        stock.isCashsale outer_is_cash_sale
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
              stock.spuCode product.outer_id.try(:strip)
              stock.itemName product.title.try(:strip)
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

  def outer_website
    website || (self.account.settings.open_auto_mark_invoice==1 ? "个人" : "" rescue "")
  end

  def type_name
    "出库单"
  end

  def confirm_sync
    so_to_wms_worker
  end

  def confirm_stock
    if can_do_stock?
      do_stock && decrease_actual && operation_logs.create(operated_at: Time.now, operation: '确认出库成功')
    end
  end

  def outer_is_cash_sale
    is_cash_sale || (self.account.settings.open_auto_mark_invoice==1 ? "需要开票" : "无需开票" rescue "无需开票")
  end

  def gqs_outer_is_cash_sale
    ((is_cash_sale == "无需开票"|| is_cash_sale.nil?) ? "0" : "1")|| (self.account.settings.open_auto_mark_invoice==1 ? "1" : "0" rescue "0")
  end

  def gqs_xml
    decorated_trade = TradeDecorator.decorate(trade)
    stock = ::Builder::XmlMarkup.new
    stock.DATA do
      stock.ORDER do
        stock.HEADER do
          stock.ORDERID tid                                                                     #YH2013030001  网站系统生成的订单编号 必填  VARCHAR2  30
          stock.ORDERDATE decorated_trade.present? ? decorated_trade.created.try(:strftime, "%Y-%m-%d %H:%M") : created_at.try(:strftime, "%Y-%m-%d %H:%M")        #2013-03-27 16:00  订单创建日期  必填  DATE
          stock.ORDERTYPE 'STD'                                #STD订单类型,淘宝订单,分销,退货
          stock.STORERID account.settings.gqs_brand_name       #品牌名
          stock.ORDERREF tid                                   #291983444180780 淘宝订单号 必填  VARCHAR2
          stock.BUYERPO  decorated_trade.present? ? decorated_trade.try(:buyer_nick) : ''       #阿里旺旺号
          stock.PMTTERM  'CC'                                  #支付方式 CC-网上支付
          stock.INVOICEFLG gqs_outer_is_cash_sale              #是否开票
          stock.INVOICENM  outer_website                         #发票偷拍
          stock.INVOICETYPE ''                                    #礼品 化妆品/ 礼品 选填  VARCHAR2  130
          stock.SHIPCONTACT op_name                               #David Kang  快递收件人全名 必填  VARCHAR2  100
          stock.SHIPADDRESS1 op_address                            #Park Hyatt Hotel  快递收件地址１ 必填  VARCHAR2  100
          stock.SHIPADDRESS2 ''                                    #快递收件地址２ 选填  VARCHAR2  100
          stock.SHIPSTATEID op_state                              #上海市 地区  必填  VARCHAR2  25
          stock.SHIPCITYID op_city                               #上海辖区  城市  必填  VARCHAR2  25
          stock.SHIPDISTRICTID op_district                           #徐汇区 省份  必填  VARCHAR2  25
          stock.SHIPZIP op_zip                                #200233  邮政编码  必填  VARCHAR2  20
          stock.SHIPPHONE op_phone                              #021-12345678  送货收件人电话 必填  VARCHAR2  80
          stock.SHIPMOBILE op_mobile                             #1381638000  送货收件人手机 必填  VARCHAR2  80
          stock.SHIPWAY ''                                    #周一到周五,上午9:00-下午5:00 送货说明  选填  VARCHAR2  100
          stock.NOTES remark                                #选填  VARCHAR2  500
          stock.TRANSMETH gqs_code                              #默认为pending,即由wms系统来决定物流公司
          stock.SHIPMENTID ""                                   #快递单号  必填  NUMBER  　默认为空
          stock.TOTALBILL bill_products_price                   #订单合计金额  必填  NUMBER  　
          stock.TOTALPIECESQTY bill_products_mumber             #订单产品合计数量  必填  NUMBER  　
        end
        bill_products.each do |product|
          stock.DETAIL do
            stock.ITEMID product.outer_id.try(:strip)
            stock.DESCR product.title.try(:strip)
            stock.QTYSHIPPED product.number
            stock.QTY product.number
            stock.UNITPRICE  product.price
          end
        end
        stock.DETAIL do
          #运费
          stock.ITEMID 'FREIGHT'
          stock.DESCR 'FREIGHT'
          stock.QTYSHIPPED 1
          stock.QTY 1
          stock.UNITPRICE  (decorated_trade.present? ? decorated_trade.try(:post_fee) : 0.0)
        end
        stock.DETAIL do
          #折扣
          stock.ITEMID 'DISCOUNT'
          stock.DESCR 'DISCOUNT'
          stock.QTYSHIPPED 1
          stock.QTY 1
          stock.UNITPRICE (decorated_trade.present? ? decorated_trade.try(:seller_discount) : 0.0)
        end
      end
    end
    stock.target!
  end

  def check
    StockProduct.transaction do
      error_activity = decrease_activity
      error_records = error_activity == true ? [] : error_activity
      if account && account.settings.enable_module_third_party_stock != 1 || self.stock_type_oinventory?
        error_actual = decrease_actual
        error_records << error_actual if error_actual != true
        self.confirm_stocked_at = self.stocked_at = Time.now
      end
      raise error_records.flatten.compact.collect{|x| '库存ID为' << x.id.to_s << ':' << x.errors.full_messages.join(',')}.join('\n') if error_records.present?
      do_check
      return true
    end
  rescue Exception => e
    e.message
  end

  def sync
    do_syncking && so_to_wms if can_do_syncking?
  end

  def rollback
    do_canceling && cancel_order_rx if can_do_canceling?
  end

  def lock!(user)
    return "不能再次锁定!" if self.operation_locked?
    notice = "同步至仓库出库单需要先撤销同步后才能锁定"
    return notice if self.status == "SYNCKED"
    return "已经同步出库单不能锁定，请先撤销同步" if !["CHECKED","CREATED","CANCELD_OK"].include?(self.status)  #"只能操作状态为: 1.已审核，待同步. 2.待审核. 3.撤销同步成功"
    self.operation = "locked"
    self.operation_time = Time.now
    build_log(user,"锁定")

    if self.status != "CREATED"
      self.increase_activity { self.save(validate: false) }
    else
      self.save(validate: false)
    end
  end

  def unlock!(user)
    return "只能操作的状态为: 已锁定." if !self.operation_locked?
    self.operation = "activated"
    self.operation_time = Time.now
    build_log(user,"激活")

    if self.status != "CREATED"
      self.decrease_activity { self.save(validate: false) }
    else
      self.save(validate: false)
    end
  end

  #推送出库单至仓库
  def so_to_wms
    BiaoganPusher.perform_async(self._id, "so_to_wms_worker")
  end

  def cancel_order_rx
    BiaoganPusher.perform_async(self._id, "cancel_order_rx_worker")
  end

  def sendable?
    if trade
      case trade._type
      when 'TaobaoTrade','CustomTrade','Trade','TaobaoPurchaseOrder'
        trade.status == "WAIT_SELLER_SEND_GOODS"
      when 'YihaodianTrade'
        trade.status == "ORDER_TRUNED_TO_DO"
      when 'JingdongTrade'
        trade.status == "WAIT_SELLER_STOCK_OUT"
      end
    else
      true
    end
  end

  def so_to_wms_worker
    if sendable?
      if account.settings.third_party_wms == "biaogan"
        result_xml = Bml.so_to_wms(account, xml)
      elsif account.settings.third_party_wms == "gqs"
        result_xml = Gqs.order_add(account, gqs_xml)
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
  end

  #发送订单取消信息至仓库
  def cancel_order_rx_worker
    if account.settings.third_party_wms == "biaogan"
      result_xml = Bml.cancel_order_rx(account, tid)
    elsif account.settings.third_party_wms == "gqs"
      result_xml = Gqs.cancel_order(account, orderid: tid,notes: '客户取消订单',opttype: 'OrderCance',opttime: Time.now.to_s(:db),method: 'OrderCance',_prefix: "order")
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

  def increase_activity(&block) #订单重新分流，或者出库单关闭，恢复仓库的可用库存
    error_records = []
    StockProduct.transaction do
      bill_products.each do |stock_out|
        stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
        if stock_product
          if !stock_product.update_attributes(activity: stock_product.activity + stock_out.number,audit_comment: "出库单ID:#{self.id}")
            error_records << stock_product.errors.full_messages
          end
        else
          # DO SOME ERROR NOTIFICATION
          false
        end
      end
      raise if error_records.present? || !(block_given? ? yield : true)
      return true
    end
  rescue Exception
    error_records
  end

  def decrease_activity(&block) #减去仓库的可用库存
    error_records = []
    StockProduct.transaction do
      bill_products.each do |stock_out|
        stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
        if stock_product
          if !stock_product.update_attributes(activity: stock_product.activity - stock_out.number,audit_comment: "出库单ID:#{self.id}")
            error_records << stock_product.errors.full_messages
          end
        else
          # DO SOME ERROR NOTIFICATION
          false
        end
      end
      raise if error_records.present? || !(block_given? ? yield : true)
      return true
    end
  rescue Exception
    error_records
  end

  def decrease_actual(&block) #减去仓库的实际库存
    error_records = []
    StockProduct.transaction do
      bill_products.each do |stock_out|
        stock_product = StockProduct.find_by_id(stock_out.stock_product_id)
        if stock_product
          if !stock_product.update_attributes(actual: stock_product.actual - stock_out.number,audit_comment: "出库单ID:#{self.id}")
            error_records << stock_product.errors.full_messages
          end
        else
          # DO SOME ERROR NOTIFICATION
          false
        end
      end
      raise if error_records.present? || !(block_given? ? yield : true)
      return true
    end
  rescue Exception
    error_records
  end

end