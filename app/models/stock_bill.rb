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
  field :is_cash_sale, type: String #无需开票/需要开票/需开专票
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
  field :operation, type: String, default: "none"
  field :operation_time, type: DateTime

  field :status, type: String

  field :bill_products_mumber, type: Integer
  field :bill_products_real_mumber, type: Integer
  field :bill_products_price, type: Float

  validates_uniqueness_of :tid, :if => :active_tid_exists?

  validates :op_name,:length => { :maximum => 50 }, :allow_blank => true
  # validates :op_phone, format: { with: /\d+-\d+/ }, :allow_blank => true
  # validates :op_mobile, length: {is: 11}, :allow_blank => true
  validates :op_address, length: {:maximum => 100}, :allow_blank => true
  validates :remark, length: {:maximum => 500}, :allow_blank => true
  validate do
    errors.add(:base,"商品不能为空") if bill_products.blank?
  end

  belongs_to :trade, :class_name => "Trade", :foreign_key => "tid",:primary_key => "tid"

  IN_STOCK_TYPE   = [["调拨入库", "IIR"], ["正常入库", "IFG"], ["拆分入库", "ICF"], ["加工入库", "IOT"], ["退货入库", "IRR"], ["特殊入库(免费)", "IMF"],["虚拟入库","IVIRTUAL"]]
  OUT_STOCK_TYPE  = [["拆分出库", "ORS"], ["调拨出库", "ODB"], ["加工出库", "OKT"], ["退货出库", "OTT"], ["销售出库", "OCM"], ["报废出库", "OOT"], ["补货出库", "OWR"], ["特殊出库(免费)", "OMF"], ["退大货出库", "OTD"],["虚拟出库","OVIRTUAL"]]

  STOCK_TYPE = IN_STOCK_TYPE + OUT_STOCK_TYPE

  enum_attr :stock_type, STOCK_TYPE
  enum_attr :operation, [['初始化',"none"],['已锁定',"locked"],['已激活','activated']]

  embeds_many :bill_products
  accepts_nested_attributes_for :bill_products, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  validates_associated :bill_products

  before_save :generate_tid

  alias_method :stock_typs=, :stock_type=

  def active_tid_exists?
    StockBill.any_in(:status.ne => 'CLOSED').where(tid: tid).exists?
  end

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
        self.tid = serial_num
      end
    end
  end

  def account
    Account.find_by_id(account_id)
  end

  def lock!
    return "不能再次锁定!" if self.operation_locked?
    notice = "同步至仓库出库单需要先撤销同步后才能锁定"
    return notice if self.status == "SYNCKED"
    return "只能操作状态为: 1.已审核，待同步. 2.待审核. 3.撤销同步成功" if !["CHECKED","CREATED","CANCELD_OK"].include?(self.status)
    self.operation = "locked"
    self.operation_time = Time.now
    self.decrease_activity if self._type == 'StockOutBill' #出库单才更新库存
    self.save(validate: false)
  end

  def unlock!
    return "只能操作的状态为: 已锁定." if !self.operation_locked?
    self.operation = "activated"
    self.operation_time = Time.now
    self.increase_activity if self._type == 'StockOutBill' #出库单才更新库存
    self.save(validate: false)
  end

  # MUST BE READ
  # 如果新建一个入库单或者更改bill_products的时候必须要调用这个
  # 为什么不用callback? 每次save都要,调用这个影响数据库IO.
  # 为什么不用 *_create or *_update 因为在update_attributes中的  bill_products的时候必须要使用attributes=
  # marked_for_destruction?才会生效. 虽然目前没有使用到. 详细看分支 stocks 最后一个commit内容.

  def update_bill_products
    bill_products.each do |bp|
      sku = Sku.where(:id => bp.sku_id).first_or_initialize
      product = sku.product || sku.build_product
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
    when "SYNCKING" then "同步中"
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
    when "CANCELING" then "撤销同步中"
    else
      status
    end
  end

  def build_log(user,identity)
    self.operation_logs.build(operated_at: Time.now, operator: user.name, operator_id: user.id, operation: identity)
  end

  def bill_products_errors
    bill_products.select {|product| !product.valid?}.collect {|x| x.errors.full_messages}.flatten.uniq
  end
end