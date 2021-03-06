#-*- encoding : utf-8 -*-
class TaobaoPurchaseOrder < Trade
  include StockProductsLockable

  field :tid, type: String,             as: :fenxiao_id
  field :deliver_id, type: String
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
  #######################################
  #REMEMBER TO UPDATE BUYER_PAYMENT TO FLOAT
  field :buyer_payment, type: Float
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
    # 支持拆分两单
    return false if self.status != "WAIT_SELLER_SEND_GOODS"
    sibling = (TaobaoPurchaseOrder.where(tid: self.tid).to_a - [self]).first
    sibling.blank? || (sibling.present? && sibling.delivered_at.present?)
  end

  def deliver!
    return unless deliverable?
    trade.update_attributes!(status: 'WAIT_BUYER_CONFIRM_GOODS')
    TradeTaobaoPurchaseOrderDeliver.perform_async(self.id)
  end

  def dispatchable?
    self.seller_id.blank? && self.status == 'WAIT_SELLER_SEND_GOODS'
  end

  def receiver_address_array
    receiver = self.receiver
    [receiver['state'], receiver['city'], receiver['district']]
  end

  def distributor_usercode
    case self.distributor_username.strip
    when "满信家居专营店"
      "TBFX0001"
    when ""
      "TBFX0002"
    else
      "无对应分销商编码"
    end
  end

  #手动分派应使用此方法
  def dispatch!(seller = nil)
    return unless self.dispatchable?

    unless seller
      seller = matched_seller
      return unless seller
    end

    if seller.has_stock
      return unless can_lock_products?(self.id, seller.id)
    end

    self.update_attributes(seller_id: seller.id, dispatched_at: Time.now) if seller

    #如果满足自动化设置条件，分派后订单自动发货
    # if auto_settings['auto_deliver'] && self.fetch_account.can_auto_deliver_right_now? && self.dispatched_at
    #   if auto_settings["deliver_condition"] == "dispatched_trade"
    #     update_attributes(delivered_at: Time.now)
    #     self.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
    #   end
    # end
  end

  def out_iids
    self.orders.map {|o| o.item_outer_id}
  end

  def cc_emails
    purchase_extra_cc = self.fetch_account.settings.purchase_extra_cc
    cc_emails = super | (purchase_extra_cc || [])
    cc_emails.compact
  end

  def orders_total_fee
    orders.inject(0.0) { |sum, order| sum + order.buyer_payment.to_f }
  end

  def payment
    orders_total_fee + post_fee
  end
end
