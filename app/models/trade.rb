class Trade
  include Mongoid::Document
  include Mongoid::Timestamps

  field :seller_id, type: Integer
  field :dispatched_at, type: DateTime  # 分流时间
  field :delivered_at, type: DateTime   # 发货时间

  field :cs_memo, type: String          # 客服备注
end