class JingdongTrade < Trade
  field :created, type: DateTime, as: :order_start_time
  field :tid, type: String,       as: :order_id

  field :vender_id, type: String
  field :pay_type, type: String
  field :order_total_price, type: Float
  field :order_payment, type: Float
  field :freight_price, type: Float
  field :seller_discount, type: Float
  field :order_state, type: String
  field :order_state_remark, type: String
  field :delivery_type, type: String
  field :invoice_info, type: String
  field :order_remark, type: String

  field :order_end_time, type: DateTime

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


  def deliver!
    TradeJingdongDeliver.perform_async(self.id)
  end

  def invoice_name
    self[:invoice_name] || self.invoice_info.split(";")[1]
  end
end