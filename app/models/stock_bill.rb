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
  attr_accessor :user,:log

  embeds_many :bill_products
  accepts_nested_attributes_for :bill_products, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  validates_associated :bill_products

  before_save :generate_tid

  alias_method :stock_typs=, :stock_type=

  state_machine :available, initial: :none,attribute: :operation do
    # 生成日志
    before_transition do: :recording
    # 还原库存
    after_transition :revert_inventory
    # 锁定
    event :lock do
      transition all - :locked => :locked       , if: lambda { |object| [:created,:checked,:canceld_ok,:synck_failed].include?(object.state_name)}
    end
    # 激活
    event :enable do
      transition all - :activated => :activated , if: lambda { |object| [:created,:checked,:canceld_ok,:synck_failed].include?(object.state_name)}
    end

    states.each do |state|
      state state.name, value: state.name.to_s
    end
  end

  state_machine :state, :initial => :created, :attribute => :status do

    before_transition do |object,transaction|
      object.errors.add(:base,"不能操作已锁定的出/入库单") && false if object.operation_locked?
    end

    # 生成日志
    before_transition do: :recording
    # 更新可用库存
    after_transition on: [:check,:stock,:special_stock], do: :update_inventory

    before_transition on: :close do |record,transition|
      record.errors.add(:base,"只有未开启第三方仓库才能关闭状态为已同步的出/入库单!") if record.account.enabled_third_party_stock? && transition.from_name == :syncked
    end
    # 如果入库类型是 期初入库, 调整入库,审核完直接入库
    after_transition on: :check           , do: :stock                , unless: :normal_check?
    # 第三方仓库同步
    after_transition on: :sync            , do: :sync_by_remote
    # 第三方仓库撤销同步
    after_transition on: :rollback        , do: :rollback_by_remote
    # 还原库存
    after_transition on: :close           , do: :revert_inventory

    # 审核
    event :check do
      transition :created => :checked,     if: :enabled_third_party_stock?
      # 如未激活第三方仓库, 直接做同步成功
      transition :created => :syncked, unless: :enabled_third_party_stock?
    end

    # 同步
    event :sync do
      transition [:synck_failed, :checked, :canceld_ok] => :syncking
    end

    # 确认同步(第三方仓库返回同步的确认接口)
    event :confirm_sync do
      transition :syncking => :syncked,       if: :enabled_third_party_stock?
    end

    # 拒绝同步(第三方仓库返回同步的失败接口)
    event :refusal_sync do
      transition :syncking => :synck_failed,  if: :enabled_third_party_stock?
    end

    # 出/入库
    event :stock do
      transition :syncked => :stocked
    end

    #特殊/出入库 用于创建出/入库单后直接 入库
    event :special_stock do
      transition :created => :stocked,if: lambda {|object| object.stock_typs == "VIRTUAL"}
    end

    # 关闭
    event :close do
      transition [:checked, :synck_failed, :canceld_ok,:syncked] => :closed
    end

    # 打开
    event :open do
      transition :closed => all - :closed
    end

    # 撤销同步
    event :rollback do
      transition [:syncked,:canceld_failed] => :canceling, if: :enabled_third_party_stock?
    end

    # 确认撤销同步(第三方仓库返回撤销同步的确认接口)
    event :confirm_rollback do
      transition :canceling => :canceld_ok,     if: :enabled_third_party_stock?
    end

    # 拒绝撤销同步(第三方仓库返回撤销同步的失败接口)
    event :refusal_rollback do
      transition :canceling => :canceld_failed, if: :enabled_third_party_stock?
    end

    states.each do |state|
      self.state(state.name, :value => state.name.upcase)
    end
  end

  # 生成日志
  def recording(transition,msg='')
    self.operation_logs.build(operated_at: Time.now, operator: user.try(:name), operator_id: user.try(:id), operation: transition.human_event << msg,text: self.log || transition.human_event << "成功")
  end

  def can_sync?
    super && %w(WAIT_SELLER_SEND_GOODS ORDER_TRUNED_TO_DO WAIT_SELLER_STOCK_OUT).include?(trade && trade.status)
  end

  # 如果为 false 则审核完之后自动入/出库
  def normal_check?
    true
  end

  # 出库时间已改为operation_logs中的operated_at, 支持以前的数据
  def stocked_at
    @stocked_at ||= (super || operation_logs.where(:text => /(出|入)库成功/).first.try(:operated_at))
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

  def account; Account.find(account_id) end

  delegate :enabled_third_party_stock? , to: :account

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
    when "RefundBill"   then "退货单"
    else ""
    end
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

  def bill_products_errors
    bill_products.select {|product| !product.valid?}.collect {|x| x.errors.full_messages}.flatten.uniq
  end

  def arrange_products(sku_id, outer_id)
    visible_products = bill_products
    visible_products = bill_products.where(sku_id: sku_id) if sku_id.present?
    visible_products = visible_products.where(outer_id: outer_id) if outer_id.present?
    visible_products
  end

  def last_record
    operation_logs.desc("operated_at").first
  end

  def last_message
    operation_logs.last.try(:text)
  end

  #推送出库单至仓库
  def sync_by_remote
    BiaoganPusher.perform_async(self._id, "push_sync_by_remote")
  end

  # 撤销同步出库单
  def rollback_by_remote
    BiaoganPusher.perform_async(self._id, "push_rollback_by_remote")
  end

  # methods
  # increase_activity(transition) 添加可用库存
  # decrease_activity(transition) 减去可用库存
  # increase_actual(transition)   添加实际库存
  # decrease_actual(transition)   减去实际库存

  [:activity, :actual].product([[:increase, :"+"], [:decrease, :"-"]]).each do |field,ary|
    prefix, sym = ary
    define_method(:"#{prefix}_#{field}") do |transition|
      transaction(transition) do
        bill_products.each do |bill_product|
          stock_product = StockProduct.find_by_id(bill_product.stock_product_id)
          self.errors.add(:base,"没有找到库存")                       if not stock_product
          self.errors.add(:base,stock_product.errors.full_messages) if stock_product &&
          !stock_product.update_attributes({field => stock_product.send(field).send(sym,bill_product.number),audit_comment: "#{type_name}ID:#{self.id}"})
        end
        fail if errors.present?
      end
    end
  end

  private
  def transaction(transition,&block)
    begin
      StockProduct.transaction(&block)
    rescue Exception
      self.log = errors.full_messages.join(',')
      recording(transition,'失败')
      update_attributes(transition.attribute => transition.from)
    ensure
      return errors.blank?
    end
  end
end