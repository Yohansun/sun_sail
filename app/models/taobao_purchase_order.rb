#-*- encoding : utf-8 -*-
class TaobaoPurchaseOrder < Trade
  field :tid, type: String,             as: :fenxiao_id
  field :seller_memo, type: String,     as: :supplier_memo
  field :buyer_message, type:String,    as: :memo
  
  #field :supplier_memo, type: String
  #field :memo, type: String

  field :pay_type, type: String
  field :trade_type, type: String
  field :distributor_from, type: String

  field :status, type: String
  field :buyer_nick, type: String
  field :tc_order_id, type: Integer

  field :receiver_name, type: String
  field :receiver_phone, type: String
  field :receiver_mobile_phone, type: String
  field :receiver_address, type: String
  field :receiver_district, type: String
  field :receiver_city, type: String
  field :receiver_zip, type: String
  field :receiver_state, type: String

  field :shipping, type: String
  field :logistics_company_name, type: String
  field :logistics_id, type: String
  field :isv_custom_key, type: String
  field :isv_custom_value, type: String
  field :end_time, type: DateTime
  field :supplier_flag, type: Integer
  field :supplier_from, type: String
  field :supplier_username, type: String
  field :distributor_username, type: String
  field :created, type: DateTime
  field :alipay_no, type: String
  field :total_fee, type: Float
  field :post_fee, type: Float
  field :distributor_payment, type: Float
  field :snapshot_url, type: String
  field :pay_time, type: DateTime
  field :consign_time, type: DateTime
  field :modified, type: DateTime

  embeds_many :taobao_sub_purchase_orders

  accepts_nested_attributes_for :taobao_sub_purchase_orders

  def orders
    self.taobao_sub_purchase_orders
  end

  def orders=(new_orders)
    self.taobao_sub_purchase_orders = new_orders
  end

  def deliverable?
    # 不限制拆分子订单的个数
    return false if self.status != "WAIT_SELLER_SEND_GOODS"
    count = TaobaoPurchaseOrder.where(tid: self.tid).count
    return true if count == 1
    status_count = TaobaoPurchaseOrder.where(tid: self.tid, status: self.status).count
    status_count == count
  end

  def deliver!
    return unless deliverable?
    TradeTaobaoPurchaseOrderDeliver.perform_async(self.id)
  end

  def dispatchable?
    seller = self.matched_seller
    seller.present? && self.seller_id.blank? && self.status == 'WAIT_SELLER_SEND_GOODS' && self.memo.blank? && self.supplier_memo.blank?
  end

  def receiver_address
    receiver = self.receiver
    [receiver['state'], receiver['city'], receiver['district']]
  end

  #手动分流应使用此方法
  def dispatch!
    return unless self.dispatchable?
    seller = self.matched_seller
    self.update_attributes(seller_id: seller.id, dispatched_at: Time.now)
  end

  def out_iids
    self.orders.map {|o| o.item_outer_id}
  end

  def cc_emails
    self.cc_emails << 'zhuyanqing@nipponpaint.com.cn'
  end  
end