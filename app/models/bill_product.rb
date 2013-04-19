class BillProduct
  include Mongoid::Document
  include NioHelper

  field :title, type: String
  field :outer_id, type: String
  field :num_iid, type: String
  field :sku_id, type: Integer
  field :colors, type: Array
  field :number, type: Integer
  field :memo, type: String
  field :price, type: Float
  field :total_price, type: Float

  belongs_to :sku
  embedded_in :deliver_bill

  def product
    Product.find_by_outer_id(outer_id) || Product.find_by_num_iid(num_iid)
  end

  def packaged?
    false
  end

  def color_info
    readable_color(colors)
  end
end
