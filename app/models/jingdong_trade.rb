class JingdongTrade < Trade
  field :created, type: DateTime,       as: :order_start_time
  field :tid, type: String,             as: :order_id
  field :buyer_message, type: String,   as: :order_remark
  field :status,type: String,           as: :order_state

  #field :order_state, type: String
  #field :order_remark, type: String

  field :vender_id, type: String
  field :pay_type, type: String
  field :order_total_price, type: Float
  field :order_seller_price, type: Float
  field :order_payment, type: Float
  field :freight_price, type: Float
  field :seller_discount, type: Float
  field :order_state_remark, type: String
  field :delivery_type, type: String
  field :invoice_info, type: String

  field :order_end_time, type: DateTime
  field :consign_time, type: DateTime
  
  field :consignee_info_fullname, type: String
  field :consignee_info_full_address, type: String
  field :consignee_info_telephone, type: String
  field :consignee_info_mobile, type: String
  field :consignee_info_province, type: String
  field :consignee_info_city, type: String
  field :consignee_info_county, type: String

  embeds_many :jingdong_orders

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

  def status=(status)
    case status
    when 'WAIT_BUYER_CONFIRM_GOODS'
      self[:status] = 'WAIT_GOODS_RECEIVE_CONFIRM'
    else
      super status
    end
  end
end