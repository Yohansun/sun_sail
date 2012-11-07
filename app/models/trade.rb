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
      @matched_logistics = Logistic.where("id in (?) AND xml IS NOT NULL", @logistic_ids).map{|ml| [ml.id, ml.name, ml.xml]}
      @matched_logistics == [] ? [[1,"其他", '']] : @matched_logistics
    else
      [[1,"其他", '']]     #无匹配地区或匹配经销商时默认是其他
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

  def self.filter(current_user, params)
    trades = Trade
    seller = current_user.seller
    logistic = current_user.logistic

    paid_not_deliver_array = ["WAIT_SELLER_SEND_GOODS","WAIT_SELLER_DELIVERY","WAIT_SELLER_STOCK_OUT"]
    paid_and_delivered_array = ["WAIT_BUYER_CONFIRM_GOODS","WAIT_GOODS_RECEIVE_CONFIRM","WAIT_BUYER_CONFIRM_GOODS_ACOUNTED","WAIT_SELLER_SEND_GOODS_ACOUNTED"]
    closed_array = ["TRADE_CLOSED","TRADE_CANCELED","TRADE_CLOSED_BY_TAOBAO", "ALL_CLOSED"]
    refund_array = ["TRADE_REFUNDING","WAIT_SELLER_AGREE","SELLER_REFUSE_BUYER","WAIT_BUYER_RETURN_GOODS","WAIT_SELLER_CONFIRM_GOODS","CLOSED", "SUCCESS"]
    succeed_array = ["TRADE_FINISHED","FINISHED_L"]

    if current_user.has_role?(:seller)
      trades = Trade.where(seller_id: seller.id) if seller
    elsif current_user.has_role?(:interface)
      trades = Trade.where(:seller_id.in => seller.child_ids) if seller
    end

    if current_user.has_role?(:logistic)
      trades = Trade.where(logistic_id: logistic.id) if logistic
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
        trade_type_hash = {"$and" => [{:created.lte => Time.now - 2.days},{:pay_time.exists => false},{:status.nin => closed_array}]}
      when 'undispatched_one_day'
        trade_type_hash = {"$and" => [{:pay_time.lte => Time.now - 1.days},{:dispatched_at.exists => false},{:seller_id.exists => false},{:status.in => paid_not_deliver_array}]}
      when 'undelivered_two_days'
        trade_type_hash = {"$and" => [{:dispatched_at.lte => Time.now - 2.days},{"$or" => [{"$and" => [{_type: "TaobaoTrade"}, {:consign_time.exists => false}]}, {"$and" => [{_type: "TaobaoPurchaseOrder"},{"$and" => [{:consign_time.exists => false}, {:delivered_at.exists => false}]}]}]},{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array}]}
      when 'buyer_delay_deliver', 'seller_ignore_deliver', 'seller_lack_product', 'seller_lack_color', 'buyer_demand_refund', 'buyer_demand_return_product', 'other_unusual_state'
        trade_type_hash = {"unusual_states" => {"$elemMatch" => {key: type, repaired_at: {"$exists" => false}}}}

      # 订单
      when 'all'
        trade_type_hash = nil
      when 'dispatched'
        trade_type_hash = {"$and" => [{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array + paid_and_delivered_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      when 'undispatched'
        trade_type_hash = {"$and" =>[{"$or" => [{seller_id: nil},{:seller_id.exists => false}]},{:status.in => paid_not_deliver_array}]}
      when 'unpaid'
        trade_type_hash = {status: "WAIT_BUYER_PAY"}
      when 'paid'
        trade_type_hash = {"$and" => [{:status.in => paid_not_deliver_array + paid_and_delivered_array + succeed_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      when 'undelivered','seller_undelivered'
        trade_type_hash = {"$and" => [{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array}]}
      when 'delivered','seller_delivered'
        trade_type_hash = {"$and" =>[{:status.in => paid_and_delivered_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      when 'refund'
        trade_type_hash = {has_refund_order: true}
      when 'closed'
        trade_type_hash = {"$and" => [{:status.in => closed_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      when 'unusual_trade'
        trade_type_hash = {"$and" => [{status: "TRADE_NO_CREATE_PAY"},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      when 'deliver_unconfirmed'
        trade_type_hash = {"$and" =>[{:seller_confirm_deliver_at.exists => false},{:status.in => paid_and_delivered_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}


      # 发货单
      # 发货单是否已打印
      when "deliver_bill_unprinted"
        trade_type_hash = {"$and" => [{:deliver_bill_printed_at.exists => false},{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array + paid_and_delivered_array}]}
      when "deliver_bill_printed"
        trade_type_hash = {"$and" => [{:deliver_bill_printed_at.exists => true},{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array + paid_and_delivered_array}]}

      # 物流单
      when "logistic_waybill_void"
        trade_type_hash = {"$and" =>[{:logistic_waybill.exists => false},{:status.in => paid_not_deliver_array}]}
      when "logistic_waybill_exist"
        trade_type_hash = {"$and" =>[{:logistic_waybill.exists => true},{:status.in => paid_not_deliver_array}]}
      when "logistic_bill_unprinted"
        # trade_type_hash = {"$and" =>[{:logistic_printed_at.exists => false},{:status.in => paid_and_delivered_array}]}
        trade_type_hash = {"$and" =>[{:logistic_printed_at.exists => false}, {"$or" => [{status: 'WAIT_SELLER_SEND_GOODS'}, {"$and"=>[{status: 'WAIT_BUYER_CONFIRM_GOODS'}, {:delivered_at.exists => true},{:delivered_at.gt => 23.hours.ago}]}]}]}
      when "logistic_bill_printed"
        # trade_type_hash = {"$and" =>[{:logistic_printed_at.exists => true},{:status.in => paid_and_delivered_array}]}
        trade_type_hash = {"$and" =>[{:logistic_printed_at.exists => true}, {"$or" => [{status: 'WAIT_SELLER_SEND_GOODS'}, {"$and"=>[{status: 'WAIT_BUYER_CONFIRM_GOODS'}, {:delivered_at.exists => true},{:delivered_at.gt => 23.hours.ago}]}]}]}

      # # 发票
      # when 'invoice_all'
      #   trade_type_hash = {:invoice_name.exists => true}
      # when 'invoice_unfilled'
      #   trade_type_hash = {:seller_confirm_invoice_at.exists => false}
      # when 'invoice_filled'
      #   trade_type_hash = {:seller_confirm_invoice_at.exists => true}
      # when 'invoice_sent'
      #   trade_type_hash = {"$and" =>[{:status.in => paid_and_delivered_array},{:seller_confirm_invoice_at.exists => true}]}

      # 调色
      when "color_unmatched"
        trade_type_hash = {"$and" => [{has_color_info: false},{:status.in => paid_not_deliver_array}]}
      when "color_matched"
        trade_type_hash = {"$and" => [{has_color_info: true},{:status.in => paid_not_deliver_array},{:confirm_color_at.exists => false}]}
      when "color_confirmed"
        trade_type_hash = {"$and" =>[{has_color_info: true},{:status.in => paid_not_deliver_array},{:confirm_color_at.exists => true}]}

      # 登录时的默认显示
      else
        # 经销商登录默认显示未发货订单
        if current_user.has_role?(:seller)
          trade_type_hash = {"$and" => [{:dispatched_at.ne => nil},{:status.in => paid_not_deliver_array}]}
        end
        # 管理员，客服登录默认显示未分流订单
        if current_user.has_role?(:cs) || current_user.has_role?(:admin)
          trade_type_hash = {"$and" => [{"$or" => [{seller_id: nil},{:seller_id.exists => false}]},{:status.in => paid_not_deliver_array}]}
        end
      end
    end


    ## 筛选
    if params[:search] && !params[:search][:simple_search_option].blank? && !params[:search][:simple_search_value].blank?
      value = /#{params[:search][:simple_search_value].strip}/
      if params[:search][:simple_search_option] == 'seller_id'
        sellers = Seller.where("name like ?", "%#{params[:search][:simple_search_value].strip}%")
        seller_ids = []
        sellers.each {|seller| seller_ids.push seller.nil? ? 0 : seller.id}
        seller_hash = {:seller_id.in => seller_ids}
      elsif params[:search][:simple_search_option] == 'receiver_name'
        receiver_name_hash = {"$or" => [{receiver_name: value}, {"consignee_info.fullname" => value}, {"receiver.name" => value}]}
      elsif params[:search][:simple_search_option] == 'receiver_mobile'
        receiver_mobile_hash = {"$or" => [{receiver_mobile: value}, {"consignee_info.mobile" => value}, {"receiver.mobile_phone" => value}]}
      else
        tid_hash = {tid: value}
      end
    end

   # 发货单打印时间筛选
    if params[:search] && params[:search][:from_deliver_print_date].present? && params[:search][:to_deliver_print_date].present?
      deliver_print_start_time = "#{params[:search][:from_deliver_print_date]} #{params[:search][:from_deliver_print_time]}".to_time(form = :local)
      deliver_print_end_time = "#{params[:search][:to_deliver_print_date]} #{params[:search][:to_deliver_print_time]}".to_time(form = :local)
      deliver_print_time_hash = {:deliver_bill_printed_at.gte => deliver_print_start_time, :deliver_bill_printed_at.lte => deliver_print_end_time}
    end

    # 物流单打印时间筛选
    if params[:search] && params[:search][:from_logistic_print_date].present? && params[:search][:to_logistic_print_date].present?
      logistic_print_start_time = "#{params[:search][:from_logistic_print_date]} #{params[:search][:from_logistic_print_time]}".to_time(form = :local)
      logistic_print_end_time = "#{params[:search][:to_logistic_print_date]} #{params[:search][:to_logistic_print_time]}".to_time(form = :local)
      logistic_print_time_hash = {:logistic_printed_at.gte => logistic_print_start_time, :logistic_printed_at.lte => logistic_print_end_time}
    end

    # 按下单时间筛选
    if params[:search] && params[:search][:search_start_date].present? && params[:search][:search_end_date].present?
      start_time = "#{params[:search][:search_start_date]} #{params[:search][:search_start_time]}".to_time(form = :local)
      end_time = "#{params[:search][:search_end_date]} #{params[:search][:search_end_time]}".to_time(form = :local)
      create_time_hash = {:created.gte => start_time, :created.lte => end_time}
    end

    # 按付款时间筛选
    if params[:search] && params[:search][:pay_start_date].present? && params[:search][:pay_end_date].present?
      pay_start_time = "#{params[:search][:pay_start_date]} #{params[:search][:pay_start_time]}".to_time(form = :local)
      pay_end_time = "#{params[:search][:pay_end_date]} #{params[:search][:pay_end_time]}".to_time(form = :local)
      pay_time_hash = {:pay_time.gte => pay_start_time, :pay_time.lte => pay_end_time}
    end

    # 按状态筛选
    if params[:search] && params[:search][:status_option].present?
      status_array = params[:search][:status_option].split(",")
      if status_array == ['require_refund']
        status_hash = {has_refund_order: true}
      else
        status_hash = {"$and" =>[{:status.in => status_array},{"$or" => [{:has_refund_order.exists => false},{has_refund_order: false}]}]}
      end
    end

    # 按来源筛选
    if params[:search] && params[:search][:type_option].present?
      type_hash = {_type: params[:search][:type_option]}
    end

    # 按省筛选
    if params[:search] && params[:search][:state_option].present?
      state = /#{params[:search][:state_option].delete("省")}/
      receiver_state_hash = {"$or" => [{receiver_state: state}, {"consignee_info.province" => state}, {"receiver.state" => state}]}
    end

    # 按市筛选
    if params[:search] && params[:search][:city_option].present? && params[:search][:city_option] != 'undefined'
      city = /#{params[:search][:city_option].delete("市")}/
      receiver_city_hash = {"$or" => [{receiver_city: city}, {"consignee_info.city" => city}, {"receiver.city" => city}]}
    end

    # 按区筛选
    if params[:search] && params[:search][:district_option].present? && params[:search][:district_option] != 'undefined'
      district = /#{params[:search][:district_option].delete("区")}/
      receiver_district_hash = {"$or" => [{receiver_district: district}, {"consignee_info.county" => district}, {"receiver.district" => district}]}
    end

    # 客服有备注
    if params[:search] && params[:search][:search_cs_memo] == "true"
      has_cs_memo_hash = {has_cs_memo: true}
    end

    # 客服无备注
    if params[:search] && params[:search][:search_cs_memo_void] == "true"
      cs_memo_void_hash = {has_cs_memo: false}
    end

    # 卖家有备注
    if params[:search] && params[:search][:search_seller_memo] == "true"
      seller_memo_hash = {"$or" => [{"$and" => [{:seller_memo.exists => true}, {:seller_memo.ne => ''}]}, {:delivery_type.exists => true}, {:invoice_info.exists => true}]}
    end

    # 客户有留言
    if params[:search] && params[:search][:search_buyer_message] == "true"
      buyer_message_hash = {"$and" => [{:buyer_message.exists => true}, {:buyer_message.ne => ''}]}
    end

    # 需要开票
    if params[:search] && params[:search][:search_invoice] == "true"
      invoice_all_hash = {"$or" => [{:invoice_name.exists => true},{:invoice_type.exists => true},{:invoice_content.exists => true}]}
    end

    # 需要调色
    if params[:search] && params[:search][:search_color] == "true"
      has_color_info_hash = {has_color_info: true}
    end

    # 不需要调色
    if params[:search] && params[:search][:search_color_void] == "true"
      color_info_void_hash = {has_color_info: false}
    end

    # 按经销商筛选
    if params[:search] && !params[:search][:search_logistic].blank? && params[:search][:search_logistic] != 'null'
      logi_name = /#{params[:search][:search_logistic].strip}/
      logistic_hash = {logistic_name: logi_name}
    end

    # 集中筛选
    if params[:search]
      search_hash = {"$and" => [
        seller_hash, tid_hash, receiver_name_hash, receiver_mobile_hash,
        deliver_print_time_hash, create_time_hash, pay_time_hash,  logistic_print_time_hash,
        status_hash, type_hash, logistic_hash,
        seller_memo_hash, buyer_message_hash, has_color_info_hash, has_cs_memo_hash, invoice_all_hash,
        cs_memo_void_hash, color_info_void_hash,
        receiver_state_hash, receiver_city_hash, receiver_district_hash,
        ].compact}
      search_hash == {"$and"=>[]} ? search_hash = nil : search_hash
    end

    ## 过滤有留言但还在抓取 + 总筛选
      chief_hash = {"$and" =>[trade_type_hash, search_hash, {"$or" => [{:has_buyer_message.ne => true}, {:buyer_message.ne => nil}]}].compact}
      unless chief_hash == {"$and"=>[]}
        trades = trades.where(chief_hash)
      end

    ###筛选结束###

  end

end
