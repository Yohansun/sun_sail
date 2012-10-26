# -*- encoding : utf-8 -*-

class Trade
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Versioning
  include Mongoid::Timestamps

  field :trade_source_id, type: Integer

  field :seller_id, type: Integer
  field :dispatched_at, type: DateTime                    # 分流时间
  field :delivered_at, type: DateTime                     # 发货时间

  field :cs_memo, type: String                            # 客服备注
  field :logistic_memo, type: String                      # 物流商备注

  # 发票信息
  field :invoice_type, type: String
  field :invoice_name, type: String
  field :invoice_content, type: String
  field :invoice_date, type: DateTime
  field :invoice_number, type: String

  field :logistic_code, type: String                      # 物流公司代码
  field :logistic_waybill, type: String                   # 物流运单号
  field :logistic_id, type: Integer
  field :logistic_name, type: String


  field :seller_confirm_deliver_at, type: DateTime        # 确认发货
  field :seller_confirm_invoice_at, type: DateTime        # 确认开票

  field :confirm_color_at, type: DateTime                 # 确认调色
  field :confirm_check_goods_at, type: DateTime           # 确认验证
  field :confirm_receive_at, type: DateTime               # 确认买家收货

  field :request_return_at, type: DateTime                # 退货相关
  field :confirm_return_at, type: DateTime
  field :confirm_refund_at, type: DateTime

  # 拆单相关
  field :splitted, type: Boolean, default: false
  field :splitted_tid, type: String

  #单据是否已打印
  field :deliver_bill_printed_at, type: DateTime
  field :logistic_printed_at, type: DateTime

  #创建新订单
  field :tid, type:String
  field :status, type:String
  field :receiver_name, type:String
  field :receiver_mobile, type:String
  field :receiver_address, type:String
  field :seller_memo, type:String

  field :has_color_info, type: Boolean, default: false
  field :has_cs_memo, type: Boolean, default: false
  field :has_unusual_state, type: Boolean, default: false
  field :has_refund_order, type: Boolean, default: false

  # add indexes for speed
  index :tid
  index :status
  index :created
  index :delivered_at
  index :dispatched_at
  index :splitted
  index :splitted_tid
  index :seller_id
  index :trade_source_id
  index :deleted_at
  index :has_color_info
  index :has_cs_memo
  index :has_unusual_state
  index :has_refund_order

  embeds_many :unusual_states
  embeds_many :operation_logs

  attr_accessor :matched_seller

  validate :color_num_do_not_exist, :on => :update

  before_update :set_has_color_info
  before_update :set_has_cs_memo
  before_update :set_has_unusual_state
  before_update :set_has_refund_order

  def set_has_color_info
    self.orders.each do |order|
      unless order.color_num.blank?
        self.has_color_info = true
        return
      end
    end
    self.has_color_info = false
    true
  end

  def set_has_refund_order
    unless self.confirm_receive_at.blank?
      self.orders.each do |order|
        if order.refund_status == 'WAIT_BUYER_RETURN_GOODS'
          self.has_refund_order = true
          return
        end
      end
    end
    self.has_refund_order = false
    true
  end

  def set_has_unusual_state
    self.unusual_states.each do |unusual_state|
      if unusual_state.repaired_at.blank?
        self.has_unusual_state = true
        return
      end
    end
    self.has_unusual_state = false
    true
  end

  def set_has_cs_memo
    unless self.cs_memo.blank?
      self.has_cs_memo = true
      return
    else
      self.orders.each do |order|
        unless order.cs_memo.blank?
          self.has_cs_memo = true
          return
        end
      end
      self.has_cs_memo = false
    end
    true
  end

  def color_num_do_not_exist
    orders.map(&:color_num).flatten.each do |color|
      next if color.blank?
      unless Color.exists?(num: color)
        errors.add(:self, "色号不存在")
        break
      end
    end
  end

  # model 属性方法
  def trade_source_name
    if trade_source_id
      TradeSource.find(trade_source_id).name
    end
  end

  # 物流公司名称
  def logistic_company
    logistic_name
  end

  def cc_emails
    if self.seller
      cc = self.seller.ancestors.map { |e|
        if e.cc_emails
          e.cc_emails.split(",")
        end
      }
      cc.flatten.compact.map { |e| e.strip }
    end
  end

  def seller(sid = seller_id)
    Seller.find_by_id sid
  end

  def default_seller(area = nil)
    area ||= default_area
    area.sellers.where(active: true).first
  end

  def matched_seller_with_default(area)
    matched_seller(area) || default_seller(area)
  end

  def matched_seller(area = nil)
    area ||= default_area
    @matched_seller ||= SellerMatcher.new(self).matched_seller(area)
  end

  def matched_logistics
    area = default_area
    if area
      @logistic_ids = LogisticArea.where(area_id: area.id).map{|l| l.logistic_id }.join(",")
      @matched_logistics = Logistic.where("id in (?)", @logistic_ids).map{|ml| [ml.id, ml.name]}
      @matched_logistics == [] ? [[1,"其他"]] : @matched_logistics
    else
      [[1,"其他"]]     #无匹配地区或匹配经销商时默认是其他
    end
  end

  def default_area
    address = self.receiver_address_array
    state = city = area = nil
    state = Area.find_by_name address[0]
    city = state.children.where(name: address[1]).first if state
    area = city.children.where(name: address[2]).first if city
    area || city || state
  end

  # 操作方法
  def deliver!
    raise "EMPTY METHOD!"
  end

  def receiver_address_array
    # overwrite this method
    # 请按照 省市区 的顺序生成array
    []
  end

  def dispatch!(seller = nil)
    # overwrite this method
  end

  def out_iids
    # overwrite this method
  end

  #清空对应trade类型的所有缓存tid
  def self.clear_cached_tids!(type)
    case type
    when 'JingdongTrade'
      jingdong_trade_tids = $redis.smembers 'JingdongTradeTids'
      jingdong_trade_tids.each do |tid|
        $redis.srem('JingdongTradeTids', tid)
      end
    when 'TaobaoTrade'
      taobao_trade_tids = $redis.smembers 'TaobaoTradeTids'
      taobao_trade_tids.each do |tid|
        $redis.srem('TaobaoTradeTids', tid)
      end
    when 'TaobaoPurchaseOrder'
      taobao_purchase_order_tids = $redis.smembers 'TaobaoPurchaseOrderTids'
      taobao_purchase_order_tids.each do |tid|
        $redis.srem('TaobaoPurchaseOrderTids', tid)
      end
    end
  end

  #清空缓存tid
  def self.clear_cached_tid(type, tid)
    case type
    when 'TaobaoPurchaseOrder'
      $redis.srem('TaobaoPurchaseOrderTids', tid)
    when 'TaobaoTrade'
      $redis.srem('TaobaoTradeTids', tid)
    when 'JingdongTrade'
      $redis.srem('JingdongTradeTids', tid)
    end
  end

  #缓存或者清空一定时间段内所有tid
  def self.cache_tids!(start_time = nil, end_time = nil, sadd_or_srem = nil)

    if start_time.blank?
      start_time = Time.now - 2.days
    end

    end_time = Time.now unless end_time

    trades = Trade.only(:tid, :_type, :created).where(:created.gte => start_time, :created.lte => end_time)

    if sadd_or_srem == "srem"
      trades.each do |trade|
        case trade._type
        when 'TaobaoPurchaseOrder'
          $redis.srem('TaobaoPurchaseOrderTids', trade.tid)
        when 'TaobaoTrade'
          $redis.srem('TaobaoTradeTids', trade.tid)
        when 'JingdongTrade'
          $redis.srem('JingdongTradeTids', trade.tid)
        end
      end
    else
      trades.each do |trade|
        case trade._type
        when 'TaobaoPurchaseOrder'
          $redis.sadd('TaobaoPurchaseOrderTids', trade.tid)
        when 'TaobaoTrade'
          $redis.sadd('TaobaoTradeTids', trade.tid)
        when 'JingdongTrade'
          $redis.sadd('JingdongTradeTids', trade.tid)
        end
      end
    end
  end
end
