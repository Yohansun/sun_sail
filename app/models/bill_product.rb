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

  belongs_to :sku
  embedded_in :deliver_bill

  def product
    Product.find_by_outer_id(outer_id) || Product.find_by_num_iid(num_iid)
  end

  def packaged?
    product && product.good_type == 2
  end

  def color_info
    readable_color(colors)
  end
end
