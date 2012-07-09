class TaobaoSubPurchaseOrder < Order
  field :status, type: String
  field :refund_fee, type: Float
  field :id, type: Integer
  field :fenxiao_id, type: Integer
  field :tc_order_id, type: Integer
  field :order_200_status, type: String
  field :auction_price, type: Float
  field :old_sku_properties, type: String
  field :item_id, type: Integer
  field :item_outer_id, type: String
  field :sku_outer_id, type: String
  field :sku_properties, type: String
  field :num, type: Integer
  field :title, type: String
  field :price, type: Float
  field :snapshot_url, type: String
  field :created, type: DateTime
  field :total_fee, type: Float
  field :distributor_payment, type: Float
  field :buyer_payment, type: Float

  embedded_in :taobao_purchase_order
end