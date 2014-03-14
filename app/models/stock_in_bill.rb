# -*- encoding:utf-8 -*-
class StockInBill < StockBill
  include Mongoid::Document
  include MagicEnum

  embeds_many :bml_input_backs
  has_one :bill_property_memo, primary_key: "tid", foreign_key: "stock_in_bill_tid"

  PUBLIC_STOCK_TYPE = PUBLIC_IN_STOCK_TYPE
  PRIVATE_STOCK_TYPE = PRIVATE_IN_STOCK_TYPE
  enum_attr :stock_type,IN_STOCK_TYPE
  validates_inclusion_of :stock_type, :in => STOCK_TYPE_VALUES

  def normal_check?
    !(stock_type_iinitial? || stock_type_icp?)
  end

  def update_inventory(transition)
    case transition.event
    when :check         then increase_activity(transition)
    when :stock         then increase_actual(transition)
    when :special_stock then increase_stock(transition)
    end
  end

  # 添加可用,实际库存
  def increase_stock(transition)
    transaction(transition) { increase_activity(transition) && increase_actual(transition) or fail}
  end

  # 还原库存
  def revert_inventory(transition)
    case transition.event
    when :lock,:close    then decrease_activity(transition)
    when :enable         then increase_activity(transition)
    end if state_name != :created
  end

  #推送入库通知单至仓库
  def push_sync_by_remote
    result_xml = case account.settings.third_party_wms
    when "biaogan" then Bml.ans_to_wms(account, xml)
    when "gqs"     then Gqs.receipt_add(account, gqs_xml)
    end

    self.log = result = Hash.from_xml(result_xml).as_json

    if    result.key?('Response') && result['Response']['success'] == 'true' then confirm_sync
    elsif result.key?('DATA')     && result['DATA']['RET_CODE']    == 'SUCC' then confirm_sync
    else  refusal_sync
    end
  end

  #发送入库单取消信息至仓库
  def push_rollback_by_remote
    result_xml = case account.settings.third_party_wms
    when "biaogan" then Bml.cancel_asn_rx(account, tid)
    when "gqs"     then Gqs.cancel_order(account, orderid: tid,notes: '客户取消订单',opttype: 'OrderCance',opttime: Time.now.to_s(:db),method: 'OrderCance',_prefix: "receipt")
    end

    self.log = result = Hash.from_xml(result_xml).as_json

    if    result.key?('Response') && result['Response']['success'] == 'true' then confirm_rollback
    elsif result.key?('DATA')     && result['DATA']['RET_CODE']    == 'SUCC' then confirm_rollback
    else  refusal_rollback
    end
  end

  def update_property_memo(memo_params, sku_id, current_account)
    self.bill_property_memo.try(:delete)
    property_memo = self.create_bill_property_memo(
    account_id: current_account.id,
    outer_id:   current_account.skus.find_by_id(sku_id).try(:product).try(:outer_id)
    )
    memo_params.each do |name, values|
      if values.is_a?(String)
        values = values.split(";")
        property_memo.property_values.create(name: name, category_property_value_id: values[0], value: values[1])
      else
        values.each do |value|
          property_memo.property_values.create(name: name, category_property_value_id: value[0], value: value[1]) if value[1].present?
        end
      end
    end
  end
  

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
end
