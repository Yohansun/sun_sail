class BillProduct
  include Mongoid::Document
  include NioHelper

  field :title, type: String
  field :outer_id, type: String
  field :colors, type: Array
  field :number, type: Integer
  field :memo, type: String

  embedded_in :deliver_bill

  def product
    Product.find_by_outer_id outer_id
  end

  def packaged?
    product && product.good_type == 2
  end

  def color_info
    readable_color(colors)
  end
end
