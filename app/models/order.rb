class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :oid, type: String
  field :refund_status, type: String, default: "NO_REFUND"

  field :total_fee, type: Float, default: 0.0
  field :payment, type: Float, default: 0.0
  field :discount_fee, type: Float, default: 0.0
  field :adjust_fee, type: Float

  field :cs_memo, type: String                    # 客服备注

  field :color_num, type: Array, default: []      # 调色字段
  field :color_hexcode, type: Array, default: []
  field :color_name, type: Array, default: []
  field :barcode, type: Array, default: []        # 条形码

  #赠品子订单专用field
  field :order_gift_tid, type: String
end