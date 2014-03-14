# -*- encoding:utf-8 -*-
class StockOutBill < StockBill
  include Mongoid::Document
  include MagicEnum
  embeds_many :bml_output_backs

  PUBLIC_STOCK_TYPE  = PUBLIC_OUT_STOCK_TYPE
  PRIVATE_STOCK_TYPE = PRIVATE_OUT_STOCK_TYPE
  enum_attr :stock_type, OUT_STOCK_TYPE
  validates_inclusion_of :stock_type, :in => STOCK_TYPE_VALUES

  def outer_website
    website || (self.account.settings.open_auto_mark_invoice==1 ? "个人" : "" rescue "")
  end

  def outer_is_cash_sale
    is_cash_sale || (self.account.settings.open_auto_mark_invoice==1 ? "需要开票" : "无需开票" rescue "无需开票")
  end

  def gqs_outer_is_cash_sale
    ((is_cash_sale == "无需开票"|| is_cash_sale.nil?) ? "0" : "1")|| (self.account.settings.open_auto_mark_invoice==1 ? "1" : "0" rescue "0")
  end

  # 更新库存
  def update_inventory(transition)
    case transition.event
    when :check         then decrease_activity(transition)
    when :stock         then decrease_actual(transition)
    when :special_stock then decrease_stock(transition)
    end
  end

  # 减可用,实际库存
  def decrease_stock(transition)
    transaction(transition) { decrease_activity(transition) && decrease_actual(transition) or fail}
  end

  # 还原库存
  def revert_inventory(transition)
    case transition.event
    when :lock,:close then increase_activity(transition)
    when :enable      then decrease_activity(transition)
    end if state_name != :created
  end

  def push_sync_by_remote
    result_xml = case account.settings.third_party_wms
    when "biaogan" then Bml.so_to_wms(account, xml)
    when "gqs"     then Gqs.order_add(account, gqs_xml)
    end

    self.log = result = Hash.from_xml(result_xml).as_json

    if    result.key?('Response') && result['Response']['success'] == 'true' then confirm_sync
    elsif result.key?('DATA')     && result['DATA']['RET_CODE']    == 'SUCC' then confirm_sync
    else  refusal_sync
    end
  end

  def update_invoice_price(price)
    # 如果只有一个子订单而且全额退款可能为负数. 邮费部分.  正常情况下这样是不会安排发货的, 还是先避免下
    price = 0 if price < 0
    # 出入库单如果在状态不是为 已审核, 同步失败, 取消成功 发送预警邮件
    if bill_products_price.to_f != price.to_f && !%w(SYNCK_FAILED CHECKED CANCELD_OK).include?(status)
      cache_exception(message: "(#{trade.shop_name})出库单在非 '已审核, 同步失败, 取消成功' 状态下 更新开票金额为#{price.to_f}",data: attributes) { raise "开票金额更新预警" }
    end
    update_attributes(bill_products_price: price)
  end

  #发送订单取消信息至仓库
  def push_rollback_by_remote
    result_xml = case account.settings.third_party_wms
    when "biaogan" then Bml.cancel_order_rx(account, tid)
    when "gqs"     then Gqs.cancel_order(account, orderid: tid,notes: '客户取消订单',opttype: 'OrderCance',opttime: Time.now.to_s(:db),method: 'OrderCance',_prefix: "order")
    end

    self.log = result = Hash.from_xml(result_xml).as_json

    if    result.key?('Response') && result['Response']['success'] == 'true' then confirm_rollback
    elsif result.key?('DATA')     && result['DATA']['RET_CODE']    == 'SUCC' then confirm_rollback
    else  refusal_rollback
    end
  end

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
end