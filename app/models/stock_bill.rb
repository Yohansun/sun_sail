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
  field :website, type: String
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
  field :seller_id, type: Integer

  field :status, type: String

  field :bill_products_mumber, type: Integer
  field :bill_products_real_mumber, type: Integer
  field :bill_products_price, type: Float

  validates_presence_of :tid

  validates_uniqueness_of :tid, message: "操作频率过大，请重试"

  validates :op_name,:length => { :maximum => 50 }, :allow_blank => true
  validates :op_phone, format: { with: /\d+-\d+/ }, :allow_blank => true
  validates :op_mobile, length: {is: 11}, :allow_blank => true
  validates :op_address, length: {:maximum => 100}, :allow_blank => true
  validates :remark, length: {:maximum => 500}, :allow_blank => true
  validate do
    errors.add(:base,"商品不能为空") if bill_products.blank?
  end

  belongs_to :trade, :class_name => "Trade", :foreign_key => "tid",:primary_key => "tid"

  IN_STOCK_TYPE   = [["调拨入库", "IIR"], ["正常入库", "IFG"], ["拆分入库", "ICF"], ["加工入库", "IOT"], ["退货入库", "IRR"], ["特殊入库(免费)", "IMF"]]
  OUT_STOCK_TYPE  = [["拆分出库", "ORS"], ["调拨出库", "ODB"], ["加工出库", "OKT"], ["退货出库", "OTT"], ["销售出库", "OCM"], ["报废出库", "OOT"], ["补货出库", "OWR"], ["特殊出库(免费)", "OMF"], ["退大货出库", "OTD"]]

  STOCK_TYPE = IN_STOCK_TYPE + OUT_STOCK_TYPE

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

  def status_text
    case status
    when "CREATED" then "待审核"
    when "CHECKED" then "已审核待同步"
    when "SYNCKED"
      if _type == "StockOutBill"
        "已同步待出库"
      else
        "已同步待入库"
      end
    when "SYNCK_FAILED" then "同步失败待同步"
    when "CLOSED" then "已关闭"
    when "STOCKED"
      if _type == "StockOutBill"
        "已出库"
      else
       "已入库"
      end
    when "CANCELD_OK" then "撤销同步成功"
    when "CANCELD_FAILED" then "撤销同步失败"
    when "CANCELING" then "撤销同步,待仓库反馈"
    else
      status
    end
  end
end