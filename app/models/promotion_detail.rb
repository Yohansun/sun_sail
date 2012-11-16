class PromotionDetail
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :id,      type: String
  field :promotion_id,      type: String
  field :promotion_name,      type: String
  field :promotion_desc,      type: String
  field :discount_fee,        type: Float

  embedded_in :taobao_trades
end