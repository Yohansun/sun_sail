class BillProduct
  include Mongoid::Document
  include NioHelper

  field :title      , type: String
  field :outer_id   , type: String
  field :num_iid    , type: String
  field :stock_product_id, type: Integer
  field :sku_id     , type: Integer
  field :colors     , type: Array
  field :number     , type: Integer ,default: 0
  field :real_number, type: Integer ,default: 0
  field :memo       , type: String
  field :price      , type: Float   ,default: 0.0
  field :total_price, type: Float   ,default: 0.0

  embedded_in :deliver_bill, :inverse_of => :bill_product
  embedded_in :stock_bill
  validates :number,:price,:total_price,:numericality => {greater_than: 0}
  validates_numericality_of :real_number,:greater_than => proc { |r| r.stock_bill.try(:_type) == "StockInBill" ? 0 : -1 }
  validates :sku_id,:presence => true

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

  def sku
    @sku ||= Sku.find_by_id(sku_id)
  end
end
