class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :cs_memo, type: String          # 客服备注

  field :color_num ,type: Array, default: []    # 调色字段
  field :color_hexcode ,type: Array, default: []
  field :color_name ,type: Array, default: []

end