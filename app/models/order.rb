class Order
  include Mongoid::Document

  field :cs_memo, type: String          # 客服备注
end