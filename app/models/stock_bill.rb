# -*- encoding:utf-8 -*-
class StockBill
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
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

  validate :uniqueness_of_active_tid_exists

  validates :op_name,:length => { :maximum => 50 }, :allow_blank => true
  # validates :op_phone, format: { with: /\d+-\d+/ }, :allow_blank => true
  # validates :op_mobile, length: {is: 11}, :allow_blank => true
  validates :op_address, length: {:maximum => 100}, :allow_blank => true
  validates :remark, length: {:maximum => 500}, :allow_blank => true
  validate do
    errors.add(:base,"商品不能为空") if bill_products.blank?
  end

  belongs_to :trade, :class_name => "Trade", :foreign_key => "tid",:primary_key => "tid"

  # 可选的入库类型
  PUBLIC_IN_STOCK_TYPE   = [["调拨入库", "IIR"], ["正常入库", "IFG"], ["拆分入库", "ICF"], ["加工入库", "IOT"], ["退货入库", "IRR"], ["特殊入库(免费)", "IMF"], ["成品入库", "ICP"]]
  # 可选的出库类型
  PUBLIC_OUT_STOCK_TYPE  = [["拆分出库", "ORS"], ["调拨出库", "ODB"], ["加工出库", "OKT"], ["退货出库", "OTT"], ["销售出库", "OCM"], ["报废出库", "OOT"], ["补货出库", "OWR"], ["特殊出库(免费)", "OMF"], ["退大货出库", "OTD"]]
  # 不可选的入库类型
  PRIVATE_IN_STOCK_TYPE   = [["期初入库","IINITIAL"],["调整入库","IVIRTUAL"]]
  # 不可选的出库类型
  PRIVATE_OUT_STOCK_TYPE = [["调整出库","OVIRTUAL"],["盘点出库","OINVENTORY"]]
  # 所有的入库类型
  IN_STOCK_TYPE = PUBLIC_IN_STOCK_TYPE + PRIVATE_IN_STOCK_TYPE
  # 所有的出库类型
  OUT_STOCK_TYPE = PUBLIC_OUT_STOCK_TYPE + PRIVATE_OUT_STOCK_TYPE

  PUBLIC_STOCK_TYPE  = PUBLIC_IN_STOCK_TYPE + PUBLIC_OUT_STOCK_TYPE

  PRIVATE_STOCK_TYPE = PRIVATE_IN_STOCK_TYPE + PRIVATE_OUT_STOCK_TYPE

  STOCK_TYPE = PUBLIC_STOCK_TYPE + PRIVATE_STOCK_TYPE

  enum_attr :stock_type, STOCK_TYPE
  enum_attr :operation, [['初始化',"none"],['已锁定',"locked"],['已激活','activated']]

  embeds_many :bill_products
  accepts_nested_attributes_for :bill_products, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  validates_associated :bill_products

  before_save :generate_tid

  alias_method :stock_typs=, :stock_type=

  state_machine :state, :initial => :created, :attribute => :status do
    #审核bill
    event :do_check do
      transition :created => :checked, :if => lambda {|bill| !bill.operation_locked? }
    end

    #同步中
    event :do_syncking do
      transition [:synck_failed, :checked, :canceld_ok] => :syncking, :if => lambda {|bill| !bill.operation_locked? }
    end

    #已同步待出/入库
    event :do_syncked do
      transition :syncking => :syncked
    end

    #同步失败
    event :do_synck_fail do
      transition :syncking => :synck_failed
    end

    #出/入库
    event :do_stock do
      transition all - [:closed,:stocked] => :stocked
    end

    #关闭
    event :do_close do
      transition [:checked, :synck_failed, :canceld_ok,:syncked] => :closed
    end

    #撤销同步
    event :do_canceling do
      transition [:syncked,:canceld_failed] => :canceling, :if => lambda {|bill| !bill.operation_locked? }
    end

    #撤销成功
    event :do_cancel_ok do
      transition :canceling => :canceld_ok
    end

    #撤销失败
    event :do_cancel_fail do
      transition :canceling => :canceld_failed
    end

    [:created, :checked, :syncking, :syncked, :synck_failed, :stocked, :canceling, :canceld_ok, :canceld_failed].each do |s_name|
      state s_name, :value => s_name.to_s.upcase
    end

    state :closed, value: "CLOSED" do
      validate do
        errors.add(:base,"只有未开启第三方仓库才能关闭状态为已同步的出/入库单!") if account.enabled_third_party_stock? && changes["status"] == ["SYNCKED", "CLOSED"]
      end
    end

    after_transition :save_change_status_timestrap
  end

  def save_change_status_timestrap
    status_keys = {:checked => "checked_at",
                   :syncking => "sync_at",
                   :syncked => "sync_succeded_at",
                   :synck_failed => "sync_failed_at",
                   :stocked => "confirm_stocked_at",
                   :canceling => "canceled_at",
                   :canceld_ok => "cancel_succeded_at",
                   :canceld_failed => "cancel_failed_at"
                  }
    attr_name = status_keys[self.state_name]
    if attr_name.present?
      self.update_attribute(attr_name, Time.now)
    end
  end

  def uniqueness_of_active_tid_exists
    scoped = self.class.where(:status.ne => 'CLOSED',tid: tid)
    exist = new_record? ? scoped.exists? : scoped.where(:_id.ne => id).exists?
    errors.add(:tid,"#{type_name}中已有相同的单号") if exist
  end

  def stock_typs=(val)
    return if stock_type == val && STOCK_TYPE_VALUES.include?(val)
    _strip = self.is_a?(StockInBill) ? "I" : self.is_a?(StockOutBill) ? "O" : ""
    self.stock_type = _strip + val.to_s
  end

  def stock_typs
    stock_type.gsub(/^(I|O)/,'')
  end

  def private_stock_type?
    PRIVATE_STOCK_TYPE.map(&:last).include?(stock_type.to_s)
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
    Account.find(account_id)
  end

  def enabled_third_party_stock?
    account.enabled_third_party_stock?
  end

  ## 改前必读 ##
  # Q: 如果新建一个入库单或者更改bill_products的时候必须要调用这个, 为什么不用callback?
  # A: 每次save都要调用这个, 影响数据库IO.
  # Q: 为什么不用 *_create or *_update
  # A: 因为在update_attributes中的 bill_products 的时候必须要使用attributes=, marked_for_destruction? 才会生效. 虽然目前没有使用到. 详细看分支 stocks 最后一个commit内容.
  def update_bill_products
    bill_products.each do |bp|
      sku = Sku.where(:id => bp.sku_id).first_or_initialize
      product = sku.product || sku.build_product
      bp.title = sku.title
      bp.outer_id = product.outer_id
      bp.num_iid = product.num_iid
      stock_product = account.stock_products.where(sku_id: sku.id, product_id: product.id, seller_id: seller_id).first
      unless stock_product
        stock_product = account.stock_products.create(product_id: product.id, seller_id: seller_id, sku_id: sku.id, num_iid: product.num_iid)
        stock_product.update_attributes(actual: 0, activity: 0)
      end
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

  def gqs_code
  end

  def type_name
    case _type
    when "StockOutBill" then "出库单"
    when "StockInBill"  then "入库单"
    else ""
    end
  end

  def last_record
    operation_logs.desc("id").first
  end

  def status_text
    case status
    when "CREATED" then "待审核"
    when "CHECKED"
      if private_stock_type?
        "已审核"
      else
        "已审核待同步"
      end
    when "SYNCKING" then "同步中"
    when "SYNCKED"
      if _type == "StockOutBill"
        enabled_third_party_stock? ? "已同步待出库" : "已审核待出库"
      else
        enabled_third_party_stock? ? "已同步待入库" : "已审核待入库"
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

  def arrange_products(sku_id, outer_id)
    visible_products = bill_products
    visible_products = bill_products.where(sku_id: sku_id) if sku_id.present?
    visible_products = visible_products.where(outer_id: outer_id) if outer_id.present?
    visible_products
  end
end