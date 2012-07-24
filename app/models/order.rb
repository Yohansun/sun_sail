class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :cs_memo, type: String          # 客服备注
end