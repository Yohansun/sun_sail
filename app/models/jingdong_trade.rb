# -*- encoding:utf-8 -*-
class JingdongTrade < Trade

  #京东特有字段
  field :pay_type,              type: String
  field :vender_id,             type: String

  field :order_seller_price,    type: Float                # 订单货款金额
  field :delivery_type,         type: String               # 送货日期类型
  field :order_state_remark,    type: String               # 中文状态
  field :return_order,          type: String               # 换货订单标识
  field :sop_stock_out_time,    type: DateTime             # sop出库时间

  #对应trade字段
  field :tid,                   as: :order_id,             type: String
  field :total_fee,             as: :order_total_price,    type: Float, default: 0.0
  field :payment,               as: :order_payment,        type: Float, default: 0.0
  field :post_fee,              as: :freight_price,        type: Float, default: 0.0
  field :discount_fee,          as: :seller_discount,      type: Float, default: 0.0

  field :status,                as: :order_state,          type: String

  field :buyer_message,         as: :order_remark,         type: String
  field :seller_memo,           as: :vender_remark,        type: String
  field :invoice_type,          as: :invoice_info,         type: String

  field :created,               as: :order_start_time,     type: DateTime
  field :pay_time,              as: :payment_confirm_time, type: DateTime
  field :end_time,              as: :order_end_time,       type: DateTime

  field :buyer_nick,            as: :pin,                  type: String
  field :receiver_name,         as: :fullname,             type: String
  field :receiver_address,      as: :full_address,         type: String
  field :receiver_phone,        as: :telephone,            type: String
  field :receiver_mobile,       as: :mobile,               type: String
  field :receiver_state,        as: :province,             type: String
  field :receiver_city,         as: :city,                 type: String
  field :receiver_district,     as: :county,               type: String

  field :logistic_id,           as: :logistics_id,         type: String
  field :logistic_waybill,      as: :waybill,              type: String


  embeds_many :jingdong_orders
  embeds_many :coupon_details


  enum_attr :status, [["等待出库"     ,"WAIT_SELLER_STOCK_OUT"],
                      ["等待确认收货"  ,"WAIT_GOODS_RECEIVE_CONFIRM"],
                      ["完成"        ,"FINISHED_L"],
                      ["取消"        ,"TRADE_CANCELED"],
                      ["已锁定"       ,"LOCKED"]],:not_valid => true

  def orders
    self.jingdong_orders
  end

  def orders=(new_orders)
    self.jingdong_orders = new_orders
  end

  ## 分派相关 ##
  def matched_seller(area = nil)
    area ||= default_area
    SellerMatcher.match_trade_seller(self.id, area)
  end

  #没有考虑物流分组和物流拆分
  def generate_deliver_bill
    deliver_bills.delete_all
    bill = deliver_bills.create(deliver_bill_number: "#{tid}01", seller_id: seller_id, seller_name: seller_name, account_id: account_id)
    orders.each do |order|
      jingdong_sku  = order.jingdong_sku || order.local_skus.first
      sku_id        = jingdong_sku.try(:id)
      sku_name      = jingdong_sku.try(:name)
      bill.bill_products.create(title: order.title, outer_sku_id: order.outer_sku_id, num_iid: order.num_iid, sku_id: sku_id, sku_name: sku_name, colors: order.color_num, number: order.num, memo: order.cs_memo)
    end
  end

  def deliver!
    return unless self.deliverable?
    TradeJingdongDeliver.perform_async(self.id)
  end

  def set_has_onsite_service
    self.has_onsite_service = false
  end
end