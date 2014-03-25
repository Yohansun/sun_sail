class BillProduct
  include Mongoid::Document
  include NioHelper

  field :title,            type: String
  field :outer_id,         type: String
  field :outer_sku_id,     type: String
  field :num_iid,          type: String
  field :oid,              type: String
  field :stock_product_id, type: Integer
  field :sku_id,           type: Integer
  field :colors,           type: Array   ,default: []
  field :number,           type: Integer ,default: 0
  field :real_number,      type: Integer ,default: 0
  field :memo,             type: String
  field :price,            type: Float   ,default: 0.0
  field :total_price,      type: Float   ,default: 0.0


  embedded_in :deliver_bill, :inverse_of => :bill_product
  embedded_in :stock_bill
  validates :number,:price,:total_price,:real_number,:numericality => {greater_than_or_equal_to: 0}
  validates :sku_id,:presence => true

  #validates :real_number, presence: true

  def product
    Product.find_by_outer_id(outer_id) || Product.find_by_num_iid(num_iid)
  end

  def color_info
    readable_color(colors)
  end

  def sku
    @sku ||= Sku.find_by_id(sku_id)
  end

  def trade
    deliver_bill.trade
  end

  def order
    trade.orders.where(oid: oid).first || trade.orders.where(outer_id: outer_id).first || trade.orders.where(num_iid: num_iid).first
  end

  def property_memos
    order ?  property_memos_visibility.flatten : []
  end

  # [
  #     [0] [
  #         [0] "26x 颜色: 82YY 85/038",
  #         [1] "    规格: 6L"
  #     ]
  # ]
  def property_memos_visibility
    group_by_property.collect do |ary, count|
      first = ary.shift
      ary = ary.collect {|x| x.to_s.insert(0,"  #{' ' * count.to_s.length}")}
      ary.unshift("#{count}x #{first}")
    end
  end

  # {["颜色: 82YY 85/038", "规格: 6L"]=>26}
  def group_by_property
    order.trade_property_memos.where(outer_id: outer_id).map(&:properties).inject(Hash.new(0)){|h,k| h[k] += 1; h}
  end

  def stock_product
    @stock_product ||= StockProduct.find_by_id(stock_product_id)
  end
end
