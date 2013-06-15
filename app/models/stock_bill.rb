# -*- encoding:utf-8 -*-
class StockBill
  include Mongoid::Document
  include Mongoid::Timestamps
  include MagicEnum
  embeds_many :bill_products
  embeds_many :operation_logs

  field :tid, type: String
  field :customer_id, type: String
  field :op_state, type: String
  field :op_city, type: String
  field :op_district, type: String
  field :op_address, type: String
  field :op_name, type: String
  field :op_mobile, type: String
  field :op_zip, type: String
  field :op_phone, type: String
  field :created_at, type: DateTime
  field :checked_at, type: DateTime
  field :stocked_at, type: DateTime
  field :confirm_stocked_at, type: DateTime #标杆反馈,确认出库时间
  field :confirm_failed_at, type: DateTime #标杆反馈,系统操作失败时间
  field :canceled_at, type: DateTime
  field :cancel_succeded_at, type: DateTime
  field :cancel_failed_at, type: DateTime
  field :failed_desc, type: String
  field :sync_at, type: DateTime
  field :sync_succeded_at, type: DateTime
  field :sync_failed_at, type: DateTime
  field :stock_id, type: Integer
  field :stock_type, type: String
  field :remark, type: String
  field :account_id, type: Integer
  field :logistic_id, type: Integer

  field :bill_products_mumber, type: Integer
  field :bill_products_real_mumber, type: Integer
  field :bill_products_price, type: Float

  validates :op_name,:length => { :maximum => 50 }, :allow_blank => true
  validates :op_phone, format: { with: /\d+-\d+/ }, :allow_blank => true
  validates :op_mobile, length: {is: 11}, :allow_blank => true
  validates :op_address, length: {:maximum => 100}, :allow_blank => true
  validates :remark, length: {:maximum => 500}, :allow_blank => true
  validate do
    errors.add(:base,"商品不能为空") if bill_products.blank?
  end

  if Rails.env.development?
    require 'stock_in_bill'
    require 'stock_out_bill'
  end

  STOCK_TYPE = StockInBill::STOCK_TYPE + StockOutBill::STOCK_TYPE
  enum_attr :stock_type, STOCK_TYPE
  validates :stock_type, :presence => true,:inclusion => { :in => STOCK_TYPE_VALUES }

  embeds_many :bill_products

  after_save :generate_tid

  alias_method :stock_typs=, :stock_type=

  def stock_typs=(val)
    return if stock_type == val && STOCK_TYPE_VALUES.include?(val)
    _strip = self.is_a?(StockInBill) ? "I" : self.is_a?(StockOutBill) ? "O" : ""
    self.stock_type = _strip + val.to_s
  end

  def stock_typs
    stock_type.gsub(/^(I|O)/,'')
  end

  def generate_tid
    if tid.blank?
      serial = Time.now.to_s(:number)
      salt = SecureRandom.hex(10).upcase[0, 3]
      serial_num = serial + salt
      if StockBill.where(tid: serial_num).exists?
        generate_tid
      else
        update_attributes!(tid: serial_num)
      end
    end
  end

  def account
    Account.find_by_id(account_id)
  end

  def update_bill_products
    bill_products.each do |bp|
      sku = Sku.find_by_id(bp.sku_id)
      product = sku.product
      bp.title = sku.title
      bp.outer_id = product.outer_id
      bp.num_iid = product.num_iid
      stock_product = account.stock_products.where(sku_id: sku.id, product_id: product.id).first
      bp.stock_product_id = stock_product.try(:id)
    end
    self.bill_products_mumber = bill_products.sum(:number)
    self.bill_products_real_mumber = bill_products.sum(:real_number)
    self.bill_products_price = bill_products.sum(:total_price)
  end

  def logistic_code
    Logistic.find_by_id(logistic_id).try(:code)
  end

  def logistic_name
    Logistic.find_by_id(logistic_id).try(:name)
  end

  def last_record
    operation_logs.desc("id").first
  end

  def status
    if checked_at
      "已审核"
    else
      "未审核"
    end
  end

  def status_text
    if sync_at
      "待标杆仓库确认出库"
    else
      "待同步标杆仓库"
    end
  end
end