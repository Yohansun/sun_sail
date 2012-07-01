class TaobaoOrder < Order
  field :oid, type: String
  field :status, type: String
  field :iid, type: String
  field :title, type: String
  field :price, type: Float
  field :num_iid, type: String
  field :item_meal_id, type: String
  field :item_meal_name, type: String
  field :sku_id, type: String
  field :num, type: Integer
  field :outer_sku_id, type: String
  field :total_fee, type: Float
  field :payment, type: Float
  field :discount_fee, type: Float
  field :adjust_fee, type: Float
  field :modified, type: DateTime
  field :sku_properties_name, type: String
  field :refund_id, type: String
  field :is_oversold, type: Boolean
  field :is_service_order, type: Boolean
  field :end_time, type: DateTime
  field :pic_path, type: String
  field :seller_nick, type: String
  field :buyer_nick, type: String
  field :refund_status, type: String
  field :outer_iid, type: String
  field :snapshot_url, type: String
  field :snapshot, type: String
  field :timeout_action_time, type: DateTime
  field :buyer_rate, type: Boolean
  field :seller_rate, type: Boolean
  field :seller_type, type: String
  field :cid, type: Integer

  embedded_in :taobao_trades
end