# -*- encoding : utf-8 -*-

class Trade
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Versioning
  include Mongoid::Timestamps

  field :trade_source_id, type: Integer

  field :seller_id, type: Integer
  field :seller_alipay_no, type: String
  field :seller_mobile, type: String
  field :seller_phone, type: String
  field :seller_name, type: String
  field :seller_email, type: String

  field :dispatched_at, type: DateTime                    # 分流时间
  field :delivered_at, type: DateTime                     # 发货时间

  field :cs_memo, type: String                            # 客服备注
  field :logistic_memo, type: String                      # 物流商备注
  field :gift_memo, type: String                          # 赠品备注

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
  field :promotion_fee, type: Float, default: 0.0         # trade.promotion_details中discount_fee的总和。

  # 拆单相关
  field :splitted, type: Boolean, default: false
  field :splitted_tid, type: String

  #单据是否已打印
  field :deliver_bill_printed_at, type: DateTime
  field :logistic_printed_at, type: DateTime

  # 单据是否拆分
  field :has_split_deliver_bill, type: Boolean, default: false

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

  field :modify_payment, type: Float
  field :modify_payment_no, type: String
  field :modify_payment_at, type: DateTime
  field :modify_payment_memo, type: String

  # add indexes for speed
  index tid: -1
  index status: 1
  index created: -1
  index delivered_at: -1
  index dispatched_at: -1
  index splitted: -1
  index splitted_tid: -1
  index seller_id: -1
  index trade_source_id: 1
  index deleted_at: 1
  index has_color_info: 1
  index has_cs_memo: 1
  index has_unusual_state: 1

  index buyer_nick: 1
  index receiver_name: 1
  index receiver_mobile: 1
  index logistic_waybill: 1
  index receiver_state: 1
  index receiver_district: 1
  index receiver_city: 1
  index deliver_bill_printed_at: -1
  index logistic_printed_at: -1

  embeds_many :unusual_states
  embeds_many :operation_logs
  embeds_many :manual_sms_or_emails

  has_many :deliver_bills

  attr_accessor :matched_seller

  validate :color_num_do_not_exist, :on => :update, :if => :color_num_changed?

  before_update :set_has_color_info
  before_update :set_has_cs_memo
  before_update :set_has_unusual_state

  def set_has_color_info
    self.orders.each do |order|
      colors = order.color_num || []
      if colors.flatten.select{|elem| elem.present?}.any?
        self.has_color_info = true
        return
      end
    end
    self.has_color_info = false
    true
  end
      
  def unusual_color_class
    class_name = ''
    if has_unusual_state
      class_name = 'cs_error'
      if TradeSetting.company == "nippon"
        class_name = unusual_states.last.unusual_color_class  if unusual_states && unusual_states.last.present? && unusual_states.last.unusual_color_class.present?
      end
    end 
    class_name   
  end 

  def set_has_unusual_state
    if unusual_states.where(:repaired_at => nil).exists?
      self.has_unusual_state = true
      return
    else  
      self.has_unusual_state = false
      true
    end
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

  def color_num_changed?
    orders.all.map(&:color_num_changed?).include? (true)
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
    emails = []

    if self.seller
      cc = self.seller.ancestors.map { |e|
        if e.cc_emails
          e.cc_emails.split(",")
        end
      }
      emails = cc.flatten.compact.map { |e| e.strip }
      emails = emails | (TradeSetting.extra_cc || [])
    end

    emails
  end

  # fetch all order cs_memo in a trade
  def orders_cs_memo
    orders.collect(&:cs_memo).compact.join(' ')
  end 

  # fetch trade cs_memo with order cs_memo
  def trade_with_orders_cs_memo
    "#{cs_memo}  #{orders_cs_memo}" 
  end

  def nofity_stock(operation, op_seller)
    return unless TradeSetting.company == 'dulux'

    orders.each do |order|
      product = Product.find_by_iid order.outer_iid
      package = product.package_info
      if package.present?
        package.each do |data|
          stock_product = StockProduct.joins(:product).where("products.iid = ? AND seller_id = ?", data[:iid], op_seller).readonly(false).first
          if stock_product.update_quantity!(data[:number] * order.num, operation)
            StockHistory.create(
              operation: operation,
              number: data[:number] * order.num,
              stock_product_id: stock_product.id,
              seller_id: op_seller.id,
              tid: tid
            )
          end
        end
      else
        stock_product = StockProduct.where(product_id: product.id, seller_id: op_seller).first
        if stock_product.update_quantity!(order.num, operation)
          StockHistory.create(
            operation: operation,
            number: order.num,
            stock_product_id: stock_product.id,
            seller_id: op_seller.id,
            tid: tid
          )
        end
      end
    end
  end

  def reset_seller
    return unless seller_id
    nofity_stock "解锁", seller_id
    update_attributes(seller_id: nil, seller_name: nil, dispatched_at: nil)
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
      @matched_logistics = Logistic.where("id in (?) AND xml IS NOT NULL", @logistic_ids).map{|ml| [ml.id, ml.name, ml.xml]}
      @matched_logistics == [] ? [[1,"其他", '']] : @matched_logistics
    else
      [[1,"其他", '']]     #无匹配地区或匹配经销商时默认是其他
    end
  end

  def generate_deliver_bill
    return if _type == 'JingdongTrade'
    #分流时生成默认发货单, 不支持京东订单

    deliver_bills.delete_all

    bill = deliver_bills.create(deliver_bill_number: "#{tid}01", seller_id: seller_id, seller_name: seller_name)
    orders.each do |order|
      bill.bill_products.create(
        title: order.title,
        iid: order.outer_iid,
        colors: order.color_num,
        number: order.num,
        memo: order.cs_memo
      )
    end    
  end

  def logistic_split
    splited = []
    orders.each do |order|
      product = Product.find_by_iid order.outer_iid

      unless product
        splited.clear
        break
      end

      case product.category.try(:name)
      when '輔助材料'
        divmod = 100000
      when '木器漆'
        divmod = 1
      else
        divmod = case product.quantity.try(:name)
        when '5L'
          3
        when '10L', '15L', '1套'
          1
        else
          splited.clear
          break
        end
      end

      div = order.num.divmod divmod

      if div[0] != 0
        div[0].times do
          splited << {
            bill: {
              id: tid + ("%02d" % (splited.size + 1)),
              number: divmod,
              title: order.title,
              iid: order.outer_iid
            }
          }
        end
      end

      if div[1] != 0
        div[1].times do
          splited << {
            bill: {
              id: tid + ("%02d" % (splited.size + 1)),
              number: 1,
              title: order.title,
              iid: order.outer_iid
            }
          }
        end
      end
    end

    splited
  end

  def split_logistic(logistic_ids)
    # 清空默认发货单
    deliver_bills.delete_all

    logistic_split.each do |item|
      iid = item[:bill][:iid]
      order = orders.select{|order| order.outer_iid == iid}.first
      color_num = order.color_num
      bill_number = item[:bill][:id]

      deliver_bill = deliver_bills.create(
        deliver_bill_number: bill_number,
        seller_id: seller_id,
        seller_name: seller_name
      )

      deliver_bill.bill_products.create(
        iid: iid,
        title: item[:bill][:title],
        number: item[:bill][:number],
        colors: color_num.pop(item[:bill][:number]),
        memo: order.cs_memo
      )

      logistic_id = logistic_ids[bill_number]
      logistic = Logistic.find logistic_id
      deliver_bill.logistic = logistic
    end

    update_attributes has_split_deliver_bill: true
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

  def self.filter(current_user, params)
    trades = Trade.all
    
    paid_not_deliver_array = ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]
    paid_and_delivered_array = ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM","WAIT_BUYER_CONFIRM_GOODS_ACOUNTED","WAIT_SELLER_SEND_GOODS_ACOUNTED"]
    closed_array = ["TRADE_CLOSED","TRADE_CANCELED","TRADE_CLOSED_BY_TAOBAO", "ALL_CLOSED"]

    #contains TaobaoOrder and SubPurchaseOrder
    taobao_trade_refund_array = ["WAIT_SELLER_AGREE","SELLER_REFUSE_BUYER","WAIT_BUYER_RETURN_GOODS","WAIT_SELLER_CONFIRM_GOODS","CLOSED", "SUCCESS"]
    taobao_purchase_refund_array = ['TRADE_REFUNDED', 'TRADE_REFUNDING']

    succeed_array = ["TRADE_FINISHED","FINISHED_L"]

    if current_user.has_role?(:seller) || current_user.has_role?(:interface)
      seller = current_user.seller
      self_and_descendants_ids = seller.self_and_descendants.map(&:id)
      trades = trades.any_in(seller_id: self_and_descendants_ids) if self_and_descendants_ids.present?
    end 
      
    if current_user.has_role? :logistic
      logistic = current_user.logistic
      trades = trades.where(logistic_id: logistic.id) if logistic
    end

    ###筛选开始####
    ## 导航栏
    if params[:trade_type]
      type = params[:trade_type]
      case type
      when 'taobao'
        trade_type_hash = {_type: 'TaobaoTrade'}
      when 'taobao_fenxiao'
        trade_type_hash = {_type: 'TaobaoPurchaseOrder'}
      when 'jingdong'
        trade_type_hash = {_type: 'JingdongTrade'}
      when 'shop'
        trade_type_hash = {_type: 'ShopTrade'}

      # 异常订单(仅适用于没有京东订单的dulux)
      when 'unpaid_two_days'
        trade_type_hash = {:created.lte => 2.days.ago, :pay_time.exists => false, status: "WAIT_BUYER_PAY"}
      when 'undispatched_one_day'
        trade_type_hash = {:pay_time.lte => 1.days.ago, :dispatched_at.exists => false, :seller_id.exists => false, :status.in => paid_not_deliver_array}
      when 'undelivered_two_days'
        trades = trades.where(:dispatched_at.lte => 2.days.ago, :consign_time.exists => false, :status.in => paid_not_deliver_array)
        trade_type_hash = {:dispatched_at.lte => 2.days.ago, :consign_time.exists => false, :status.in => paid_not_deliver_array}
      when 'buyer_delay_deliver', 'seller_ignore_deliver', 'seller_lack_product', 'seller_lack_color', 'buyer_demand_refund', 'buyer_demand_return_product', 'other_unusual_state'
        trade_type_hash = {:unusual_states.elem_match => {:key => type, :repaired_at.exists => false}}
      # 订单
      when 'all'
        trade_type_hash = nil
      when 'dispatched'
        trade_type_hash = {:dispatched_at.ne => nil, :status.in => paid_not_deliver_array + paid_and_delivered_array}
      when 'undispatched'
        trade_type_hash = {:status.in => paid_not_deliver_array, seller_id: nil}
      when 'unpaid'
        trade_type_hash = {status: "WAIT_BUYER_PAY"}
      when 'paid'
        trade_type_hash = {:status.in => paid_not_deliver_array + paid_and_delivered_array + succeed_array}
      when 'undelivered','seller_undelivered'
        trade_type_hash = {:dispatched_at.ne => nil, :status.in => paid_not_deliver_array}
      when 'delivered','seller_delivered'
        trade_type_hash = {:status.in => paid_and_delivered_array}
      when 'refund'
        trade_type_hash ={"$or" => [{ :"taobao_orders.refund_status" => {:'$in' => taobao_trade_refund_array}}, {:"taobao_sub_purchase_orders.status" => {:'$in' => taobao_purchase_refund_array}}]}
      when 'return'
        trade_type_hash = {:request_return_at.ne => nil}  
      when 'closed'
        trade_type_hash = {:status.in => closed_array}
      when 'unusual_trade'
        trade_type_hash = {status: "TRADE_NO_CREATE_PAY"}
      when 'deliver_unconfirmed'
        trade_type_hash = {:seller_confirm_deliver_at.exists => false, :status.in => paid_and_delivered_array}

      # 发货单
      # 发货单是否已打印
      when "deliver_bill_unprinted"
        trade_type_hash = {:deliver_bill_printed_at.exists => false, :dispatched_at.ne => nil, :status.in => paid_not_deliver_array + paid_and_delivered_array}
      when "deliver_bill_printed"
        trade_type_hash = {:deliver_bill_printed_at.exists => true, :dispatched_at.ne => nil, :status.in => paid_not_deliver_array + paid_and_delivered_array}

      # 物流单
      when "logistic_waybill_void"
        trade_type_hash = {:logistic_waybill.exists => false, :status.in => paid_not_deliver_array}
      when "logistic_waybill_exist"
        trade_type_hash = {:logistic_waybill.exists => true, :status.in => paid_not_deliver_array + paid_and_delivered_array + succeed_array}
      when "logistic_bill_unprinted"
        trade_type_hash = {"$and" => [{"logistic_printed_at" =>{"$exists" => false}}, {"$or" => [{status: 'WAIT_SELLER_SEND_GOODS'}, {status: 'WAIT_BUYER_CONFIRM_GOODS', "delivered_at" => {"$gt" => 23.hours.ago}}]}]}
      when "logistic_bill_printed"
        trade_type_hash = {"$and" => [{"logistic_printed_at" =>{"$exists" => true}}, {"$or" => [{status: 'WAIT_SELLER_SEND_GOODS'}, {status: 'WAIT_BUYER_CONFIRM_GOODS', "delivered_at" => {"$gt" => 23.hours.ago}}]}]}

      # # 发票
      # when 'invoice_all'
      #   trade_type_hash = {:invoice_name.exists => true}
      # when 'invoice_unfilled'
      #   trade_type_hash = {:seller_confirm_invoice_at.exists => false}
      # when 'invoice_filled'
      #   trade_type_hash = {:seller_confirm_invoice_at.exists => true}
      # when 'invoice_sent'
      #   trade_type_hash = {:status.in => paid_and_delivered_array, :seller_confirm_invoice_at.exists => true}

      #退货
      when 'request_return'
        trade_type_hash = {:request_return_at.exists => true}
      when 'confirm_return'
        trade_type_hash = {:confirm_return_at.exists => true}

      # 调色
      when "color_unmatched"
        trade_type_hash = {has_color_info: false, :status.in => paid_not_deliver_array}
      when "color_matched"
        trade_type_hash = {has_color_info: true, :status.in => paid_not_deliver_array, :confirm_color_at.exists => false}
      when "color_confirmed"
        trade_type_hash = {has_color_info: true, :status.in => paid_not_deliver_array, :confirm_color_at.exists => true}

      # 登录时的默认显示
      else
        # 经销商登录默认显示未发货订单
        if current_user.has_role?(:seller)
          trades = trades.where(:dispatched_at.ne => nil, :status.in => paid_not_deliver_array)
        end
        # 管理员，客服登录默认显示未分流订单
        if current_user.has_role?(:cs) || current_user.has_role?(:admin)
          trades = trades.where(:status.in => paid_not_deliver_array, seller_id: nil)
        end
      end
    end

    ## 筛选
    if params[:search]
      if !params[:search][:simple_search_option].blank? && !params[:search][:simple_search_value].blank?
        value = /#{params[:search][:simple_search_value].strip}/
        if params[:search][:simple_search_option] == 'seller_id'
          seller_ids = Seller.select(:id).where("name like ?", "%#{params[:search][:simple_search_value].strip}%").map &:id
          simple_search_hash = {"seller_id" => {"$in" => seller_ids}}
        elsif params[:search][:simple_search_option] == 'receiver_name'
          simple_search_hash = {"$or" => [{receiver_name: value}, {"consignee_info.fullname" => value}, {"receiver.name" => value}]}
        elsif params[:search][:simple_search_option] == 'receiver_mobile'
          simple_search_hash = {"$or" => [{receiver_mobile: value}, {"consignee_info.mobile" => value}, {"receiver.mobile_phone" => value}]}
        else
          simple_search_hash = Hash[params[:search][:simple_search_option].to_sym, value]
        end
      end

      # 发货单打印时间筛选
      if params[:search][:from_deliver_print_date].present? && params[:search][:to_deliver_print_date].present?
        deliver_print_start_time = "#{params[:search][:from_deliver_print_date]} #{params[:search][:from_deliver_print_time]}".to_time(form = :local)
        deliver_print_end_time = "#{params[:search][:to_deliver_print_date]} #{params[:search][:to_deliver_print_time]}".to_time(form = :local)
        deliver_print_time_hash = {"$and" => [{"deliver_bill_printed_at" => {"$gte" => deliver_print_start_time}}, {"deliver_bill_printed_at" => {"$lte" => deliver_print_end_time}}]}
      end

      # 物流单打印时间筛选
      if params[:search][:from_logistic_print_date].present? && params[:search][:to_logistic_print_date].present?
        logistic_print_start_time = "#{params[:search][:from_logistic_print_date]} #{params[:search][:from_logistic_print_time]}".to_time(form = :local)
        logistic_print_end_time = "#{params[:search][:to_logistic_print_date]} #{params[:search][:to_logistic_print_time]}".to_time(form = :local)
        logistic_print_time_hash = {"$and" => [{"logistic_printed_at" => {"$gte" => logistic_print_start_time}}, {"logistic_printed_at" => {"$lte" => logistic_print_end_time}}]}
      end

      # 按下单时间筛选
      if params[:search][:search_start_date].present? && params[:search][:search_end_date].present?
        start_time = "#{params[:search][:search_start_date]} #{params[:search][:search_start_time]}".to_time(form = :local)
        end_time = "#{params[:search][:search_end_date]} #{params[:search][:search_end_time]}".to_time(form = :local)
        create_time_hash = {"$and" => [{"created" => {"$gte" => start_time}}, {"created" => {"$lte" => end_time}}]}
      end

      # 按付款时间筛选
      if params[:search][:pay_start_date].present? && params[:search][:pay_end_date].present?
        pay_start_time = "#{params[:search][:pay_start_date]} #{params[:search][:pay_start_time]}".to_time(form = :local)
        pay_end_time = "#{params[:search][:pay_end_date]} #{params[:search][:pay_end_time]}".to_time(form = :local)
        pay_time_hash = {"$and" => [{"pay_time" => {"$gte" => pay_start_time}}, {"pay_time" => {"$lte" => pay_end_time}}]}
      end

      # 按状态筛选
      if params[:search][:status_option].present?
        status_array = params[:search][:status_option].split(",")
        status_hash = {"status" =>{"$in" => status_array}}
      end

      # 按分流时间筛选
      if params[:search] && params[:search][:dispatch_start_date].present? && params[:search][:dispatch_end_date].present?
        dispatch_start_time = "#{params[:search][:dispatch_start_date]} #{params[:search][:dispatch_start_time]}".to_time(form = :local)
        dispatch_end_time = "#{params[:search][:dispatch_end_date]} #{params[:search][:dispatch_end_time]}".to_time(form = :local)
        dispatch_time_hash = {"$and" => [{"dispatched_at" => {"$gte" => dispatch_start_time}}, {"dispatched_at" => {"$lte" => dispatch_end_time}}]}
      end

      # 按来源筛选
      if params[:search][:type_option].present?
        type_hash = {_type: params[:search][:type_option]}
      end

      # 按省筛选
      if params[:search][:state_option].present?
        state = /#{params[:search][:state_option].delete("省")}/
        receiver_state_hash = {"$or" => [{receiver_state: state}, {"consignee_info.province" => state}, {"receiver.state" => state}]}
      end

      # 按市筛选
      if params[:search][:city_option].present? && params[:search][:city_option] != 'undefined'
        city = /#{params[:search][:city_option].delete("市")}/
        receiver_city_hash = {"$or" => [{receiver_city: city}, {"consignee_info.city" => city}, {"receiver.city" => city}]}
      end

      # 按区筛选
      if params[:search][:district_option].present? && params[:search][:district_option] != 'undefined'
        district = /#{params[:search][:district_option].delete("区")}/
        receiver_district_hash = {"$or" => [{receiver_district: district}, {"consignee_info.county" => district}, {"receiver.district" => district}]}
      end

      # 客服有备注
      if params[:search][:search_cs_memo] == "true"
        has_cs_memo_hash = {has_cs_memo: true}
      end

      # 客服无备注
      if params[:search][:search_cs_memo_void] == "true"
        cs_memo_void_hash = {has_cs_memo: false}
      end

      # 卖家有备注
      if params[:search][:search_seller_memo] == "true"
        seller_memo_hash = {"$or" => [{"$and" => [{"seller_memo" => {"$exists" => true}}, {"seller_memo" => {"$ne" => ''}}]}, {"delivery_type" => {"$exists" => true}}, {"invoice_info" => {"$exists" => true}}]}
      end

      # 客户有留言
      if params[:search][:search_buyer_message] == "true"
        buyer_message_hash = {"buyer_message" => {"$nin" => ['', nil]}}
      end

      # 需要开票
      if params[:search][:search_invoice] == "true"
        invoice_all_hash = {"$or" => [{"invoice_name" => {"$exists" => true}},{"invoice_type" => {"$exists" => true}},{"invoice_content" => {"$exists" => true}}]}
      end

      # 需要调色
      if params[:search][:search_color] == "true"
        has_color_info_hash = {has_color_info: true}
      end

      # 不需要调色
      if params[:search][:search_color_void] == "true"
        color_info_void_hash = {has_color_info: false}
      end

      # 按经销商筛选
      if params[:search][:search_logistic].present?
        logi_name = /#{params[:search][:search_logistic].strip}/
        logistic_hash = {logistic_name: logi_name}
      end
    end

    # 集中筛选
    search_hash = {"$and" => [
      trade_type_hash, deliver_print_time_hash,     create_time_hash,         pay_time_hash,
      logistic_print_time_hash,    status_hash,              type_hash,
      logistic_hash,               seller_memo_hash,         buyer_message_hash,
      has_color_info_hash,         has_cs_memo_hash,         invoice_all_hash,
      cs_memo_void_hash,           color_info_void_hash,     receiver_state_hash,
      receiver_city_hash,          receiver_district_hash,   simple_search_hash,
      dispatch_time_hash
    ].compact}
    search_hash == {"$and"=>[]} ? search_hash = nil : search_hash

    ## 过滤有留言但还在抓取 + 总筛选
    trades.where(search_hash).where({"$or" => [{"has_buyer_message" => {"$ne" => true}},{"buyer_message" => {"$ne" => nil}}]})
    ###筛选结束###
  end
end
