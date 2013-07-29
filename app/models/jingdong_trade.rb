class JingdongTrade < Trade

  #京东特有字段
  field :pay_type, type: String
  field :vender_id, type: String

  field :order_seller_price, type: Float   # 订单货款金额
  field :delivery_type, type: String       # 送货日期类型
  field :order_state_remark, type: String  # 中文状态
  field :return_order, type: String        # 换货订单标识
  field :pin, type: String                 # 买家账号信息

  #对应trade字段
  field :order_id,          as: :tid, type: String
  field :order_total_price, as: :total_fee, type: Float
  field :order_payment,     as: :order_payment, type: Float
  field :freight_price,     as: :post_fee, type: Float
  field :seller_discount,   as: :discount_fee, type: Float

  field :order_state,       as: :status, type: String

  field :order_remark,      as: :buyer_message, type: String
  field :vender_remark,     as: :seller_memo, type: String
  field :invoice_info,      as: :invoice_type, type: String

  field :order_start_time,  as: :created, type: DateTime
  ## 京东订单无付款时间！！ ##
  field :order_end_time,    as: :consign_time, type: DateTime

  field :fullname,          as: :receiver_name, type: String
  field :full_address,      as: :receiver_address, type: String
  field :telephone,         as: :receiver_phone, type: String
  field :mobile,            as: :receiver_mobile, type: String
  field :province,          as: :receiver_state, type: String
  field :city,              as: :receiver_city, type: String
  field :county,            as: :receiver_district, type: String

  embeds_many :jingdong_orders
  embeds_many :coupon_details

  def orders
    self.jingdong_orders
  end

  def orders=(new_orders)
    self.jingdong_orders = new_orders
  end

  def deliver!
    TradeJingdongDeliver.perform_async(self.id)
  end

  def invoice_name
    unless self[:invoice_name].present?
    self[:invoice_name] = self.invoice_info.split(";")[1]
    self.save
    end
    return self[:invoice_name]
  end

  def post_fee
    freight_price.blank?  ?  0  :  freight_price
  end

  def total_fee
    order_seller_price.to_f + post_fee.to_f - seller_discount.to_f
  end

  def status=(status)
    case status
    when 'WAIT_BUYER_CONFIRM_GOODS'
      self[:status] = 'WAIT_GOODS_RECEIVE_CONFIRM'
    else
      super status
    end
  end
end