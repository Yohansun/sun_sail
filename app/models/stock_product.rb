# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: stock_products
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  max        :integer(4)      default(0)
#  safe_value :integer(4)      default(0)
#  activity   :integer(4)      default(0)
#  actual     :integer(4)      default(0)
#  product_id :integer(4)
#  seller_id  :integer(4)
#  sku_id     :integer(8)
#  num_iid    :integer(8)
#  account_id :integer(4)
#  forecast   :integer(4)      default(0)
#

class StockProduct < ActiveRecord::Base
  audited
  # paginates_per 20

  belongs_to :account

  attr_accessible :max, :safe_value, :product_id, :seller_id, :color_ids, :actual, :activity, :sku_id, :num_iid, :account_id

  validates_numericality_of :safe_value, :actual, :activity, :max, greater_than_or_equal_to: 0, message: '数量不能小于零'

  # This should be, but not proper to validate it.
  # validates_numericality_of :activity, less_than_or_equal_to: :actual

  validates_presence_of :product_id, :account_id, message: '必填项'

  belongs_to :product
  belongs_to :sku
  belongs_to :seller
  has_one :category , :through => :product,:source => :category
  has_and_belongs_to_many :colors
  scope :with_account, ->(account_id) { where(:account_id => account_id) }

  STORAGE_STATUS = {
    "预警" => "stock_products.activity < stock_products.safe_value",
    "满仓" => "stock_products.actual = stock_products.max",
    "正常" => "stock_products.activity >= stock_products.safe_value and stock_products.actual != stock_products.max"
  }

  def self.batch_update_actual_stock(relation,number)
    success = []
    fails = []
    relation.each do |record|
      record.update_actual_stock(number,__method__) ? success.push(record.id) : fails.push(record.id)
    end
    [success,fails]
  end

  def update_actual_stock(actual,action)
    transaction do
      self.actual = actual
      self.changes[:actual].tap do |ary|
        poor = ary.first - ary.last
        self.activity -= poor
        self.audit_comment = action || __method__
        klass = poor > 0 ? StockOutBill : StockInBill
        return true if self.save! && create_stock_bill(klass,poor.abs)
      end if self.actual_changed?
    end rescue false
  end

  def storage_status
    if activity < safe_value
      '预警'
    elsif actual == max
      '满仓'
    else
      '正常'
    end
  end

  def self.can_inventory?
    default_scopes = inventory_scopes

    bill_status = %w(CHECKED SYNCKED SYNCKING SYNCK_FAILED CANCELD_OK CANCELING CANCELD_FAILED)
    trade_status = %w(WAIT_SELLER_SEND_GOODS WAIT_SELLER_DELIVERY WAIT_SELLER_STOCK_OUT ORDER_PAYED ORDER_TRUNED_TO_DO)
    !(StockOutBill.where(default_scopes.merge(status: bill_status)).exists? &&
    Trade.where(default_scopes.(status: trade_status)).exists?)
  end

  def self.inventory!
    stock_out_bill = StockOutBill.where(inventory_scopes).new({
      stock_type:                 "OINVENTORY",
      bill_products_mumber:       scoped.sum(:actual),
      bill_products_price:        scoped.joins(:product).sum("products.price * stock_products.actual")
      })

    StockProduct.where(inventory_scopes).find_each do |stock_product|
      stock_out_bill.bill_products.new(stock_product.generate_out_bill_attributes)
    end

    stock_out_bill.save!
  end

  def self.inventory_scopes
    conditions = scoped.where_values_hash
    raise "account_id & seller_id can't be blank!" unless conditions.key?(:account_id) && conditions.key?(:seller_id)

    conditions = conditions.slice(:account_id,:seller_id)
    raise "当前已有未审核的盘点出库单!" if  StockOutBill.where(conditions.merge(stock_type: "OINVENTORY",status: "CREATED")).exists?
    conditions
  end

  def generate_out_bill_attributes(options={})
    product = self.product
    sku = self.sku
    {
      title:        sku.title,
      outer_id:     product.outer_id,
      num_iid:      sku.num_iid,
      stock_product_id: self.id,
      number:       self.actual,
      sku_id:       self.sku_id,
      price:        product.price,
      total_price:  product.price * self.actual
    }.merge(options)
  end

  private
  def create_stock_bill(klass,number)
    bill = klass.new(stock_typs: "VIRTUAL", status: "STOCKED",stocked_at: Time.now, confirm_stocked_at: Time.now, seller_id: self.seller_id ,account_id: self.account_id,bill_products_attributes: {"0" => generate_out_bill_attributes(number: number)})
    bill.update_bill_products
    bill.save!
  end
end
