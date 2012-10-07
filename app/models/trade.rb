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

  # 发票信息
  field :invoice_type, type: String
  field :invoice_name, type: String
  field :invoice_content, type: String
  field :invoice_date, type: DateTime
  field :invoice_number, type: String

  field :logistic_code, type: String                      # 物流公司代码
  field :logistic_waybill, type: String                   # 物流运单号

  field :seller_confirm_deliver_at, type: DateTime        # 确认发货
  field :seller_confirm_invoice_at, type: DateTime        # 确认开票

  field :confirm_color_at, type: DateTime                 #确认调色
  field :confirm_check_goods_at, type: DateTime           #确认验证

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
  field :has_unusual_state, type:Boolean, default: false

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

  embeds_many :unusual_states

  attr_accessor :matched_seller

  validate :color_num_do_not_exist, :on => :update

  before_update :set_has_color_info
  before_update :set_has_cs_memo
  before_update :set_has_unusual_state

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
    color_nums = Color.all.map {|color| color.num}
    count = 0
    total_num = 0
    self.orders.each do |order|
      num = self._type == "JingdongTrade" ? order.item_total : order.num
      num.times do |i|
        if (order.color_num[i] == nil && order.color_num != []) || order.color_num[i] == ""
          count += 1
        end
        for color_num in color_nums
          if order.color_num[i] == color_num
            count += 1
            break
          end
        end
      end
      if order.color_num == []
        count += num
      end
      total_num += num
    end
    if count != total_num
      errors.add(:self, "Blank color_num")
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
    case logistic_code
    when 'YTO'
      '圆通快递'
    when 'ZTO'
      '中通速递'
    else
      '其他'
    end
  end

  def cc_emails
    extra_cc = %W(E-Business@nipponpaint.com.cn shenweiyu@nipponpaint.com.cn zhangqin@nipponpaint.com.cn wuhangjun@nipponpaint.com.cn ZhaoMengMeng@nipponpaint.com.cn caozhixiong@nipponpaint.com.cn shaolixing@nipponpaint.com.cn YanFei.Allen@nipponpaint.com.cn gaoyulin@nipponpaint.com.cn)
    if self.seller
      cc = self.seller.ancestors.map { |e|
        if e.cc_emails
          e.cc_emails.split(",")
        end
      }.flatten.compact.map { |e| e.strip }  << extra_cc
      cc.flatten
    end
  end

  def seller
    if self.seller_id
      Seller.find(self.seller_id)
    end
  end

  def matched_seller_with_default(area)
    matched_seller(area) || Seller.default_seller
  end

  def matched_seller(area = nil)
    area ||= default_area
    @matched_seller ||= SellerMatcher.new(self).matched_seller(area)
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