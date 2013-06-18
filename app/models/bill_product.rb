class BillProduct
  include Mongoid::Document
  include NioHelper

  field :title, type: String
  field :outer_id, type: String
  field :num_iid, type: String
  field :stock_product_id, type: Integer
  field :sku_id, type: Integer
  field :colors, type: Array
  field :number, type: Integer
  field :real_number, type: Integer, default: 0
  field :memo, type: String
  field :price, type: Float
  field :total_price, type: Float

  embedded_in :deliver_bill, :inverse_of => :bill_product
  embedded_in :stock_bill

  #validates :real_number, presence: true

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
