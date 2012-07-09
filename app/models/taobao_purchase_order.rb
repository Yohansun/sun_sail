class TaobaoPurchaseOrder < Trade
  field :supplier_memo, type: String
  field :fenxiao_id, type: Integer
  field :pay_type, type: String
  field :trade_type, type: String
  field :distributor_from, type: String
  field :id, type: Integer

  field :status, type: String
  field :buyer_nick, type: String
  field :memo, type: String
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
end