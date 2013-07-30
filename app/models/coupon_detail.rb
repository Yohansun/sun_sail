class CouponDetail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :coupon_price,        type: Float
  field :coupon_type,         type: String
  field :order_id,  as: :oid, type: String
  field :sku_id,              type: String

  embedded_in :jingdong_trades
end