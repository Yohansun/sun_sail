#encoding: utf-8
class RefundProduct < ActiveRecord::Base
  attr_protected []
  include MagicEnum
  has_many :refund_orders,:inverse_of => :refund_product,:dependent => :destroy
  belongs_to :account
  accepts_nested_attributes_for :refund_orders, :allow_destroy => true
  validates_associated :refund_orders
  validates :account_id,:tid,:address,:buyer_name,:refund_time,:presence => true
  validates :refund_id,:uniqueness => {:scope => :ec_name}
  scope :can_edit, -> { where(:status => %w(created checked revocation)) }

  validate do
    errors.add(:base,"退货订单不能为空") if refund_orders.blank?
    errors.add(:tid,"出库单中没有找到订单号为#{tid}") if stock_in_bill.nil?
    errors.add(:base,"退货商品不能一样") if refund_orders.length != refund_orders.map(&:sku_id).uniq.length
  end

  serialize :status_operations, Array
  before_create do
    self.status_operations = [{:created => Time.now}]
  end

  before_save :init

  scope :with_account, ->(account_id) { where(account_id: account_id)}

  enum_attr :status, [["待审核","created"],["已审核待同步","checked"],["已同步","syncked"],["仓库已确认","recognize"],["已锁定","locked"],["已激活",'enabled'],["已撤销同步","revocation"]]

  state_machine :state, :initial => :created,:attribute => :status do
    after_transition :put_operation
    after_transition :on => :enable, :do => :restore_state
    event :check do
      transition :created => :checked
    end

    event :sync do
      transition [:checked,:revocation] => :syncked
    end

    event :locking do
      transition [:created,:checked,:revocation] => :locked
    end

    event :enable do
      transition :locked => :enabled
    end

    event :rollback do
      transition :syncked => :revocation
    end

    event :confirm do
      transition :syncked => :recognize
    end

    state :syncked do
      validate do
        response = send_request(account.settings.third_party_wms,:syncked)
        response = Hash.from_xml(response).as_json
        response,stat,desc = parse_result(response)
        errors.add(:base,"同步失败: #{response}") if stat.blank?
        errors.add(:base,"同步失败: #{desc}")     if stat && !stat.match(/true|SUCC/)
      end
    end

    state :revocation do
      validate do
        response = send_request(account.settings.third_party_wms,:revocation)
        response = Hash.from_xml(response).as_json
        response,stat,desc = parse_result(response)
        errors.add(:base,"撤销同步失败: #{response}") if stat.blank?
        errors.add(:base,"撤销同步失败: #{desc}")     if stat && !stat.match(/true|SUCC/)
      end
    end
  end

  #第三方仓库调用的
  private :confirm

  def restore_state

    if !status_enabled?
      errors.add(:status,"必须是已锁定")
      return false
    end

    self.status = last_operation_status
    self.save
  end

  def last_operation
    status_operations.reject {|x| x.key?(:locked) || x.key?(:enabled)}.last
  end
  
  def last_operation_status
    last_operation.keys.first.to_s
  end

  def build_log(user,identity)
    self.operation_logs.build(operated_at: Time.now, operator: user.name, operator_id: user.id, operation: identity)
  end

  def refund_orders_errors
    refund_orders.select {|product| !product.valid?}.collect {|x| x.errors.full_messages}.flatten.uniq
  end

  %w(area_state area_city area_district).each do |c|
    define_method("#{c}_name") do
      instance_variable_get("@#{c}") || instance_variable_set("@#{c}", Area.find_by_id(send(:"#{c.gsub(/area_/,'')}_id")).try(:name))
    end
  end

  def syncked_biaogan
    stock = ::Builder::XmlMarkup.new
    stock.RequestPurchaseInfo do
      stock.warehouseid "BML_KSWH"
      stock.type "RR"
      stock.orderCode tid
      stock.customerId account.settings.biaogan_customer_id
      stock.ZDRQ created_at.try(:strftime, "%Y-%m-%d %H:%M")
      stock.DHRQ refund_time.try(:strftime, "%Y-%m-%d %H:%M")
      stock.ZDR ""
      stock.BZ  reason
      stock.products do
        refund_orders.each do |product|
          stock.productInfo do
            stock.spuCode product.outer_id
            stock.itemName product.title
            stock.itemCount product.num
            stock.itemValue product.refund_price
            stock.remark ""
          end
        end
      end
    end
    stock.target!
  end

  def stock_in_bill
    StockOutBill.find_by(:tid => tid) rescue nil
  end

  def syncked_gqs
    stock = ::Builder::XmlMarkup.new
    stock.DATA do
      stock.RECEIPT do
        stock.HEADER do
          stock.RECEIPTID tid
          stock.RECEIPTDATE refund_time.to_s(:db)
          stock.ORDERTYPE 'RETURN'
          stock.POID tid                                                        #采购单号
          stock.TOTALPIECESQTY refund_orders.map(&:num).sum
          stock.SHIPCONTACT buyer_name
          stock.SHIPSTATEID area_state_name
          stock.SHIPCITYID  area_city_name
          stock.SHIPDISTRICTID  area_district_name
          stock.SHIPADDRESS2  address
        end

        refund_orders.each do |product|
          stock.DETAIL do
            stock.ITEMID product.outer_id
            stock.STATUSID 1
            stock.DESCR product.title
            stock.QTYRECEIVED product.num
            stock.QTY product.num
            stock.UNITPRICE  product.bill_product.price
          end
        end
      end
    end
    stock.target!
  end

  private
  def init
    self.refund_id = Time.now.to_f.to_s.gsub('.','').to(15) if refund_id.blank?
    self.refund_fee = refund_orders.map(&:refund_price).sum
  end

  def put_operation
    self.status_operations << {state_name => Time.now}
    self.save
  end

  # biaogan   {'Response': {'success':'true','desc':'xxx'}}
  # gqs       {'DATA': {'RET_CODE':'SUCC','RET_MESSAGE':'xxx'}}
  # will be convert to:
  # {'response' => {'code' => 'true', 'desc' => 'xxx' }}
  # {'response' => {'code' => 'SUCC', 'desc' => 'xxx' }}
  def parse_result(response)
    stat,desc = [nil] * 2
    response.each do |k,v|
      if /Response|DATA/ =~ k
        response = v
        v.each do |k2,v2|
          stat = v2.to_s if /success|RET_CODE/ =~ k2
          desc = v2.to_s if /desc|RET_MESSAGE/ =~ k2
        end if v.is_a?(Hash)
      end
    end
    [response,stat,desc]
  end

  def send_request(name,stat)
    case name
    when 'biaogan'
      if stat == :revocation
        Bml.cancel_asn_rx(account, tid)
      elsif stat == :syncked
        Bml.ans_to_wms(account, syncked_biaogan)
      end
    when 'gqs'
      if stat == :revocation
        Gqs.cancel_order(account, receiptid: tid,notes: '不接受客户退货！',opttype: 'ReceiptCancel',opttime: Time.now.to_s(:db),method: 'RcptCancel',_prefix: "receipt")
      elsif stat == :syncked
        Gqs.receipt_add(account, syncked_gqs)
      end
    end
  end
end
