#encoding:utf-8
class RefundOrder < ActiveRecord::Base
  attr_protected []
  belongs_to :refund_product,:inverse_of => :refund_orders
  belongs_to :account
  validates :refund_price,:num, :presence => true
  scope :with_account, ->(account_id) { where(account_id: account_id) }
  belongs_to :sku
  delegate :tid, to: :refund_product,:allow_nil => true

  validate do
    if bill_product.nil?
      if product = bill_products.where(num_iid: num_iid).first
        self.sku_id = product.sku_id if self.sku_id.blank?
        errors.add(:sku_id,"出库单订单号为:#{tid}没有找到sku_id为#{sku_id}的记录") if !bill_products.where(sku_id: sku_id).exists?
      else
        errors.add(:num_iid,"没有找到出库单中商品数字编号为#{num_iid}")
      end
      errors.add(:sku_id,"不能为空") if sku_id.blank?
    else
      errors.add(:sku_id,"商品SKU ID和此订单的出库单的商品不一致")    if self.sku_id != bill_product.sku_id
      validates_numericality_of :num          ,less_than_or_equal_to: ->(object) { object.bill_product.number      if object.bill_product },:greater_than => 0
      validates_numericality_of :refund_price ,less_than_or_equal_to: ->(object) { object.bill_product.total_price if object.bill_product },:greater_than => 0
    end
  end

  before_save :init

  def stock_out_bill
    @stock_out_bill ||= StockOutBill.find_by(tid: tid.to_s) rescue nil
  end

  def bill_product
    @bill_product ||= stock_out_bill && stock_out_bill.bill_products.find_by(:sku_id => sku_id) rescue nil
  end

  def bill_products
    stock_out_bill && stock_out_bill.bill_products
  end

  def init
    self.account_id = refund_product.account_id
    self.seller_id  = refund_product.seller_id
    self.order_type = stock_out_bill.trade.try(:_type)
    self.title      = bill_product.title                    if self.title.blank?
    self.outer_id   = bill_product.outer_id
    self.num_iid    = bill_product.num_iid                  if self.num_iid.blank?
    self.stock_product_id = bill_product.stock_product_id
  end
end
