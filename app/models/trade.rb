# -*- encoding : utf-8 -*-

class Trade
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :trade_source_id, type: Integer

  field :account_id, type: Integer
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
  field :deliver_bills_count, type: Integer, default: 0

  # 拆单相关
  field :splitted, type: Boolean, default: false
  field :splitted_tid, type: String

  #单据是否已打印
  field :deliver_bill_printed_at, type: DateTime
  field :logistic_printed_at, type: DateTime

  # 单据是否拆分
  field :has_split_deliver_bill, type: Boolean, default: false

  # 金额调整
  field :modify_payment, type: Float
  field :modify_payment_no, type: String
  field :modify_payment_at, type: DateTime
  field :modify_payment_memo, type: String

  #创建新订单
  field :tid, type:String
  field :area_id, type: Integer
  field :status, type:String
  field :receiver_name, type:String
  field :receiver_mobile, type:String
  field :receiver_address, type:String
  field :seller_memo, type:String

  field :has_color_info, type: Boolean, default: false
  field :has_cs_memo, type: Boolean, default: false
  field :has_unusual_state, type: Boolean, default: false
  field :has_onsite_service, type: Boolean, default: false

  # ADD INDEXES TO SPEED UP
  # 简单搜索index
  index tid: -1
  index buyer_nick: 1
  index receiver_name: 1
  index receiver_mobile: 1
  index seller_id: 1
  index logistic_name: 1
  index logistic_waybill: -1
  index "unusual_states.repair_man" => 1

  # 时间搜索index
  index created: -1
  index pay_time: -1
  index dispatched_at: -1
  index delivered_at: -1
  index consign_time: -1
  index rate_created: -1
  index deliver_bill_printed_at: -1
  index logistic_printed_at: -1
  # index seller_confirm_deliver_at: -1
  # index seller_confirm_invoice_at: -1
  # index confirm_check_goods_at: -1
  # index confirm_receive_at: -1
  # index confirm_color_at: -1
  # index request_return_at: -1
  # index confirm_return_at: -1
  # index confirm_refund_at: -1


  # 金额搜索index
  index payment: 1

  # 状态搜索index
  index status: 1
  # index splitted: -1
  # index splitted_tid: -1
  # index trade_source_id: 1

  # 信息搜索index
  # index has_color_info: 1
  # index has_cs_memo: 1
  # index has_unusual_state: 1
  # index has_onsite_service: 1
  # index has_buyer_message: 1

  # 来源搜索index
  # index _type: 1

  # 区域搜索index
  index receiver_state: 1
  index receiver_district: 1
  index receiver_city: 1

  embeds_many :unusual_states
  embeds_many :operation_logs
  embeds_many :manual_sms_or_emails
  embeds_many :trade_gifts

  has_many :deliver_bills
  has_one :stock_out_bill

  attr_accessor :matched_seller

  validate :color_num_do_not_exist, :on => :update, :if => :color_num_changed?

  before_update :set_has_color_info
  before_update :set_has_cs_memo
  before_update :set_has_unusual_state
  after_destroy :check_associate_deliver_bills

  def fetch_account
    Account.find_by_id(self.account_id)
  end

  def fields_for_gift_trade
    fields = {}
    fields["seller_nick"] = seller_nick
    fields["buyer_nick"] = buyer_nick
    fields["account_id"] = account_id
    fields["trade_source_id"] = trade_source_id
    fields["receiver_name"] = receiver_name
    fields["receiver_mobile"] = receiver_mobile
    fields["receiver_phone"] = receiver_phone
    fields["receiver_address"] = receiver_address
    fields["receiver_zip"] = receiver_zip
    fields["receiver_state"] = receiver_state
    fields["receiver_city"] = receiver_city
    fields["receiver_district"] = receiver_district
    fields["status"] = 'WAIT_SELLER_SEND_GOODS'
    fields["created"] = Time.now
    fields["pay_time"] = Time.now
    fields["custom_type"] = "gift_trade"

    return fields
  end

  def add_gift_order(value)
    gift_sku = Sku.where(product_id: value['product_id'].to_i).first
    gift_product = Product.find(value['product_id'].to_i)
    self.taobao_orders.create!(_type: "TaobaoOrder",
                               oid: self.tid.slice(/G[0-9]$/),
                               status: "WAIT_SELLER_SEND_GOODS",
                               title: value['gift_title'],
                               price: 0,
                               total_fee: 0,
                               payment: 0,
                               discount_fee: 0,
                               adjust_fee: 0,
                               num_iid: gift_sku.num_iid,
                               sku_id: gift_sku.sku_id,
                               num: 1, # NEED ADAPTION?
                               pic_path: gift_product.pic_url,
                               refund_status: "NO_REFUND",
                               sku_properties_name: "赠品", # NEED ADAPTION?
                               buyer_rate: false,
                               seller_rate: false,
                               seller_type: "B",
                               cid: gift_product.cid)
  end

  def unusual_color_class
    class_name = ''
    if has_unusual_state
      class_name = 'cs_error'
      if fetch_account.key == "nippon"
        class_name = unusual_states.last.unusual_color_class  if unusual_states && unusual_states.last.present? && unusual_states.last.unusual_color_class.present?
      end
    end
    class_name
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
      emails = emails | (fetch_account.settings.extra_cc || [])
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

  def reset_seller
    return unless seller_id
    update_attributes(seller_id: nil, seller_name: nil, dispatched_at: nil)
    deliver_bills.delete_all
  end

  def seller(sid = seller_id)
    Seller.find_by_id sid
  end

  def default_seller(area = nil)
    area ||= default_area
    area.sellers.where(active: true, account_id: account_id).first
  end

  def matched_seller_with_default(area)
    matched_seller(area, account_id) || default_seller(area, account_id)
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

  def can_deliver_in_logistic_group?
    enable = fetch_account.settings.enable_module_logistic_group
    return false unless enable == 1
    items = []
    taobao_orders.each do |order|
      order.package_products.each do |p|
        items << p.logistic_group_id
      end
    end
    !items.include?(nil)
  end

  def logistic_group_products
    items = []
    taobao_orders.each do |order|
      order.num.times{
        order.package_products.each do |p|
          item = {order_id: order.id, product_id: p.id, num: 1, logistic_group_id: p.logistic_group_id}
          items << item
        end
      }
    end
    items
  end

  def logistic_groups
    groups = {}
    logistic_group_products.each do |product|
      logistic_group_id = product.fetch(:logistic_group_id)
      groups[logistic_group_id] ||= 0
      groups[logistic_group_id] += product.fetch(:num)
    end

    splited_groups = {}
    groups.each do |logistic_group_id, num|
      logistic_group = LogisticGroup.find_by_id(logistic_group_id)
      split_number = logistic_group.split_number
      divmod = num.divmod(split_number)
      splited_groups[logistic_group_id] = [divmod[0], divmod[1]]
    end
    splited_groups
  end

  def logistic_group(id)
    products = []
    logistic_group_products.each do |logistic_group_product|
      logistic_group_id = logistic_group_product.fetch(:logistic_group_id)
      products << logistic_group_product if logistic_group_id == id
    end
    products
  end

  def generate_stock_out_bill
    return if stock_out_bill.present?
    bill = StockOutBill.create(trade_id: _id, tid: tid, op_state:receiver_state, op_city: receiver_city, op_district: receiver_district, op_address: receiver_address,
      op_name: receiver_name, op_mobile: receiver_mobile, op_zip: receiver_zip, op_phone: receiver_phone, logistic_id: logistic_id, remark: cs_memo,
      stock_type: "CM", account_id: account_id, checked_at: Time.now, created_at: Time.now
    )
    orders.each do |order|
      if order.sku_bindings.present?
        order.sku_bindings.each do |binding|
          sku_id = binding.sku_id
          sku = Sku.find_by_id(binding.sku_id)
          product = sku.try(:product)
          if product
            binding_number = binding.number
            stock_product = fetch_account.stock_products.where(product_id: product.id, sku_id: sku_id).first
            if stock_product
              bill.bill_products.build(
                stock_product_id: stock_product.id,
                title: sku.title,
                outer_id: product.outer_id,
                sku_id: sku_id,
                price: product.price,
                total_price: product.price * binding_number,
                number: binding_number,
                remark: order.cs_memo
              )
            else
              # DO SOME RESCUE
            end
          else
              # DO SOME RESCUE
          end
        end
      else
        # DO SOME RESCUE
      end
    end
    bill.bill_products_mumber = bill.bill_products.sum(:number)
    bill.bill_products_price = bill.bill_products.sum(:total_price)
    bill.save
    bill.decrease_activity #减去仓库的可用库存
  end

  # SKU属性不全
  def generate_deliver_bill
    return if _type == 'JingdongTrade'
    #分流时生成默认发货单, 不支持京东订单
    deliver_bills.delete_all
    if can_deliver_in_logistic_group?
      logistic_groups.each do |logistic_group_id, divmod|
        logistic_group = LogisticGroup.find_by_id(logistic_group_id)
        split_number = logistic_group.split_number
        all_items = logistic_group(logistic_group_id)
        div = divmod[0]
        mod = divmod[1]
        count = 0
        div.times{
          items = all_items.pop(split_number)
          bill = deliver_bills.create(deliver_bill_number: "#{tid}#{logistic_group_id}#{count}", seller_id: seller_id, seller_name: seller_name, account_id: account_id)
          items.each do |item|
            product_id = item.fetch(:product_id)
            product = Product.find_by_id(product_id)
            order_id = item.fetch(:order_id)
            order = taobao_orders.where(id: order_id).first
            num_iid = order.num_iid
            outer_iid = product.outer_id
            sku = order.sku
            sku_id = sku.try(:id)
            sku_name = sku.try(:name)
            title = sku.try(:title)
            num_iid = order.num_iid.to_s
            bill_product = bill.bill_products.where(outer_id: outer_iid, num_iid: num_iid).first
            if bill_product
              bill_product.number += 1
              bill_product.save
            else
              bill.bill_products.create(title: title ,outer_id: outer_iid, stock_product_id: stock_product.id, num_iid: num_iid, sku_id: sku_id, sku_name: sku_name, colors: order.color_num,number: 1, memo: order.cs_memo)
            end
          end
          count += 1
        }
        if mod > 0
          count = div.times.to_a.count
          bill = deliver_bills.create(deliver_bill_number: "#{tid}#{logistic_group_id}#{count}", seller_id: seller_id, seller_name: seller_name, account_id: account_id)
          all_items.each do |item|
            product_id = item.fetch(:product_id)
            product = Product.find_by_id(product_id)
            order_id = item.fetch(:order_id)
            order = taobao_orders.where(id: order_id).first
            num_iid = product.num_iid
            outer_iid = product.outer_id
            sku = order.sku
            sku_id = sku.try(:id)
            sku_name = sku.try(:name)
            title = sku.try(:title)
            num_iid = order.num_iid.to_s
            bill_product = bill.bill_products.where(outer_id: outer_iid, num_iid: num_iid).first
            if stock_product
              stock_product_id = stock_product.id
              bill_product = bill.bill_products.where(outer_id: outer_iid, num_iid: num_iid).first
              if bill_product
                bill_product.number += 1
                bill_product.save
              else
                bill.bill_products.create(title: title, outer_id: outer_iid, num_iid: num_iid, sku_id: sku_id, sku_name: sku_name, colors: order.color_num,number: 1, memo: order.cs_memo)
              end
            else
              bill.bill_products.create(title: title, outer_id: outer_iid, num_iid: num_iid, sku_id: sku_id, sku_name: sku_name, colors: order.color_num, number: 1, memo: order.cs_memo)
            end
          end
        end
      end
    else
      bill = deliver_bills.create(deliver_bill_number: "#{tid}01", seller_id: seller_id, seller_name: seller_name, account_id: account_id)
      orders.each do |order|
        taobao_sku = order.taobao_sku
        sku_id = taobao_sku.try(:id)
        sku_name = taobao_sku.try(:name)
        bill.bill_products.create(title: order.title, outer_id: order.outer_iid, num_iid: order.num_iid, sku_id: sku_id, sku_name: sku_name, colors: order.color_num, number: order.num, memo: order.cs_memo)
      end
    end

  end

  def logistic_split
    splited = []
    # orders.each do |order|
    #   product = Product.find_by_outer_id order.outer_iid

    #   unless product
    #     splited.clear
    #     break
    #   end

    #   case product.category.try(:name)
    #   when '輔助材料'
    #     divmod = 100000
    #   when '木器漆'
    #     divmod = 1
    #   else
    #     divmod = case product.quantity.try(:name)
    #     when '5L'
    #       3
    #     when '10L', '15L', '1套'
    #       1
    #     else
    #       splited.clear
    #       break
    #     end
    #   end

    #   div = order.num.divmod divmod

    #   if div[0] != 0
    #     div[0].times do
    #       splited << {
    #         bill: {
    #           id: tid + ("%02d" % (splited.size + 1)),
    #           number: divmod,
    #           title: order.title,
    #           outer_id: order.outer_iid
    #         }
    #       }
    #     end
    #   end

    #   if div[1] != 0
    #     div[1].times do
    #       splited << {
    #         bill: {
    #           id: tid + ("%02d" % (splited.size + 1)),
    #           number: 1,
    #           title: order.title,
    #           outer_id: order.outer_iid
    #         }
    #       }
    #     end
    #   end
    # end

    # splited
  end

  def split_logistic(logistic_ids)
    # 清空默认发货单
    deliver_bills.delete_all

    logistic_split.each do |item|
      outer_id = item[:bill][:outer_id]
      order = orders.select{|order| order.outer_iid == outer_id}.first
      color_num = order.color_num
      bill_number = item[:bill][:id]

      deliver_bill = deliver_bills.create(
        deliver_bill_number: bill_number,
        seller_id: seller_id,
        seller_name: seller_name
        )

      deliver_bill.bill_products.create(
        outer_id: outer_id,
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

  def custom_type
    # overwrite this method
  end

  def main_trade_id
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

  # 订单筛选
  def self.filter(current_account, current_user, params)
    trades = Trade.where(account_id: current_account.id)

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
      end

      # 异常订单(仅适用于没有京东订单的帐户)
      auto_unusual = current_account.settings.auto_settings["auto_mark_unusual_trade"]
      unusual_auto_setting = current_account.settings.auto_settings["unusual_conditions"]
      if auto_unusual && unusual_auto_setting
        case type
        when 'unpaid_for_days'
          if unusual_auto_setting['unusual_waitpay']
            trade_type_hash = {:created.lte => unusual_auto_setting['max_unpay_days'].to_i.days.ago, pay_time: nil, status: "WAIT_BUYER_PAY"}
          end
        when 'undispatched_for_days'
          if unusual_auto_setting['unusual_dispatch']
            trade_type_hash = {:pay_time.lte => unusual_auto_setting['max_undispatch_days'].to_i.days.ago, dispatched_at: nil, seller_id: nil, :status.in => paid_not_deliver_array}
          end
        when 'undelivered_for_days'
          if unusual_auto_setting['unusual_deliver']
            trade_type_hash = {:dispatched_at.lte => unusual_auto_setting['max_undeliver_days'].to_i.days.ago, consign_time: nil, :status.in => paid_not_deliver_array}
          end
        when 'unreceived_for_days'
          if unusual_auto_setting['unusual_receive']
            trade_type_hash = {:unusual_states.elem_match => {key: "unreceived_in_#{unusual_auto_setting['max_unreceived_days']}_days", :repaired_at => nil}}
          end
        when 'unrepaired_for_days'
          if unusual_auto_setting['unusual_repair']
            trade_type_hash = {:unusual_states.elem_match => {:plan_repair_at => {"$lte" => (Time.now - unusual_auto_setting['max_unrepaired_days'].to_i.days)}, repaired_at: nil}}
          end
        end
      end

      # 订单
      case type
      when 'my_buyer_delay_deliver', 'my_seller_ignore_deliver', 'my_seller_lack_product', 'my_seller_lack_color', 'my_buyer_demand_refund', 'my_buyer_demand_return_product', 'my_other_unusual_state'
        trade_type_hash = {:unusual_states.elem_match => {:repair_man => current_user.name, :key => type.slice(3..-1), :repaired_at => nil}}
      when 'unusual_for_you'
        trade_type_hash = {:unusual_states.elem_match => {:repair_man => current_user.name, repaired_at: nil}}
      when 'buyer_delay_deliver', 'seller_ignore_deliver', 'seller_lack_product', 'seller_lack_color', 'buyer_demand_refund', 'buyer_demand_return_product', 'other_unusual_state'
        trade_type_hash = {:unusual_states.elem_match => {:key => type, repaired_at: nil}}
      when 'unusual_all'
        trade_type_hash = {:unusual_states.elem_match =>{:repaired_at => nil}, :unusual_states.nin => [[],nil]}
      when 'all'
        trade_type_hash = nil
      when 'dispatched'
        trade_type_hash = {:dispatched_at.ne => nil, :status.in => paid_not_deliver_array + paid_and_delivered_array}
      when 'undispatched'
        trade_type_hash = {:status.in => paid_not_deliver_array, seller_id: nil, has_unusual_state: false, :pay_time.ne => nil}
      when 'unpaid'
        trade_type_hash = {status: "WAIT_BUYER_PAY"}
      when 'paid'
        trade_type_hash = {:status.in => paid_not_deliver_array + paid_and_delivered_array + succeed_array}
      when 'undelivered','seller_undelivered'
        trade_type_hash = {:dispatched_at.ne => nil, :status.in => paid_not_deliver_array, has_unusual_state: false}
      when 'delivered','seller_delivered'
        trade_type_hash = {:status.in => paid_and_delivered_array, has_unusual_state: false}
      when 'refund'
        trade_type_hash = {"$or" => [{ :"taobao_orders.refund_status" => {:'$in' => taobao_trade_refund_array}}, {:"taobao_sub_purchase_orders.status" => {:'$in' => taobao_purchase_refund_array}}]}
      when 'return'
        trade_type_hash = {:request_return_at.ne => nil}
      when 'closed'
        trade_type_hash = {:status.in => closed_array}
      when 'unusual_trade'
        trade_type_hash = {status: "TRADE_NO_CREATE_PAY"}
      when 'deliver_unconfirmed'
        trade_type_hash = {seller_confirm_deliver_at: nil, :status.in => paid_and_delivered_array}

        # 发货单
        # 发货单是否已打印
      when "deliver_bill_unprinted"
        trade_type_hash = {deliver_bill_printed_at: nil, :dispatched_at.ne => nil, :status.in => paid_not_deliver_array + paid_and_delivered_array}
      when "deliver_bill_printed"
        trade_type_hash = {:deliver_bill_printed_at.ne => nil, :dispatched_at.ne => nil, :status.in => paid_not_deliver_array + paid_and_delivered_array}

        # 物流单
      when "logistic_waybill_void"
        trade_type_hash = {logistic_waybill: nil, :status.in => paid_not_deliver_array}
      when "logistic_waybill_exist"
        trade_type_hash = {:logistic_waybill.ne => nil, :status.in => paid_not_deliver_array + paid_and_delivered_array + succeed_array}
      when "logistic_bill_unprinted"
        trade_type_hash = {"$and" => [{"logistic_printed_at" => nil}, {"$or" => [{status: 'WAIT_SELLER_SEND_GOODS'}, {status: 'WAIT_BUYER_CONFIRM_GOODS', "delivered_at" => {"$gt" => 23.hours.ago}}]}]}
      when "logistic_bill_printed"
        trade_type_hash = {"$and" => [{"logistic_printed_at" =>{"$ne" => nil}}, {"$or" => [{status: 'WAIT_SELLER_SEND_GOODS'}, {status: 'WAIT_BUYER_CONFIRM_GOODS', "delivered_at" => {"$gt" => 23.hours.ago}}]}]}

        # # 发票
        # when 'invoice_all'
        #   trade_type_hash = {:invoice_name.ne => nil}
        # when 'invoice_unfilled'
        #   trade_type_hash = {seller_confirm_invoice_at: nil}
        # when 'invoice_filled'
        #   trade_type_hash = {:seller_confirm_invoice_at.ne => nil}
        # when 'invoice_sent'
        #   trade_type_hash = {:status.in => paid_and_delivered_array, :seller_confirm_invoice_at.ne => nil}

        #退货
      when 'request_return'
        trade_type_hash = {:request_return_at.ne => nil, confirm_return_at: nil}
      when 'confirm_return'
        trade_type_hash = {:confirm_return_at.ne => nil}

        # 调色
      when "color_unmatched"
        trade_type_hash = {has_color_info: false, :status.in => paid_not_deliver_array}
      when "color_matched"
        trade_type_hash = {has_color_info: true, :status.in => paid_not_deliver_array, confirm_color_at: nil}
      when "color_confirmed"
        trade_type_hash = {has_color_info: true, :status.in => paid_not_deliver_array, :confirm_color_at.ne => nil}

        # 登录时的默认显示
      when "default"
          # 经销商登录默认显示未发货订单
          if current_user.has_role?(:seller)
            trades = trades.where(:dispatched_at.ne => nil, :status.in => paid_not_deliver_array)
          end
          # 管理员，客服登录默认显示未分流淘宝订单
          if current_user.has_role?(:cs) || current_user.has_role?(:admin)
            trades = trades.where(:status.in => paid_not_deliver_array, seller_id: nil).where(_type: 'TaobaoTrade')
          end
        end
      end

    ## 筛选
    if params[:search]

      search_tags_hash = {}
      area_search_hash = {}
      params[:search].each do |key,value|
        value_array = value.split(";")
        length = value_array.length
        case length
        # 简单搜索＋来源搜索
        when 1
          if value.present?
            regexp_value = /#{value.strip}/
            if key == 'seller_id'
              seller_ids = Seller.select(:id).where("name like ?", "%#{value.strip}%").map(&:id)
              search_tags_hash.update({"seller_id" => {"$in" => seller_ids}})
            elsif key == 'receiver_name'
              search_tags_hash.update({"$or" => [{receiver_name: regexp_value}, {"consignee_info.fullname" => regexp_value}, {"receiver.name" => regexp_value}]})
            elsif key == 'receiver_mobile'
              search_tags_hash.update({"$or" => [{receiver_mobile: regexp_value}, {"consignee_info.mobile" => regexp_value}, {"receiver.mobile_phone" => regexp_value}]})
            elsif key == 'repair_man'
              search_tags_hash.update({"unusual_states" =>{"$elemMatch" => {"repair_man" => regexp_value}}})
            else
              search_tags_hash.update(Hash[key.to_sym, value])
            end
          end

        # 状态筛选＋时间筛选＋金额筛选
        when 2
          if value_array[1] == "true" || value_array[1] == "false"
            if value_array[0].present?
              status_array = value_array[0].split(",")
              search_tags_hash.update({key =>{"$in" => status_array}})
            end
          else
            if value_array[0].present? && value_array[1].present?
              if value_array[0].include?('-')
                start_time = value_array[0].to_time(:local)
                end_time = value_array[1].to_time(:local)
                search_tags_hash.update({key => {"$gte" => start_time, "$lt" => end_time}})
              else
                min_money = value_array[0].to_f
                max_money = value_array[1].to_f
                search_tags_hash.update({key => {"$gte" => min_money, "$lt" => max_money}})
              end
            end
          end

        # 地域筛选
        when 3
            # 按省筛选
            if value_array[2].present?
              state = /#{value_array[2].delete("省")}/
              state_search_hash = {"$or" => [{receiver_state: state}, {"consignee_info.province" => state}, {"receiver.state" => state}]}
            end
            # 按市筛选
            if value_array[1].present?
              city = /#{value_array[1].delete("市")}/
              city_search_hash = {"$or" => [{receiver_city: city}, {"consignee_info.city" => city}, {"receiver.city" => city}]}
            end
            # 按区筛选
            if value_array[0].present?
              district = /#{value_array[0].delete("区")}/
              district_hash = {"$or" => [{receiver_district: district}, {"consignee_info.county" => district}, {"receiver.district" => district}]}
            end
            area_search_hash = {"$and" => [state_search_hash,city_search_hash,district_hash].compact}
            area_search_hash == {"$and"=>[]} ? area_search_hash = nil : area_search_hash

        # 信息筛选
        when 4
          words = (value_array[3] == "true" ? /#{value_array[2]}/ : /^[^#{value_array[2]}]+$/) if value_array[2].present?
          if value_array[1] == "true"
            not_void = {"$nin" => ['', nil]}
            if key == "has_color_info"
              search_tags_hash.update(Hash[key.to_sym, true])
              search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"$and" => [{"color_num" => words},{"color_hexcode" => words},{"color_name" => words}]}}}) if words
            elsif key == "has_cs_memo"
              search_tags_hash.update(Hash[key.to_sym, true])
              search_tags_hash.update({"$or" => [{"cs_memo" => words},{"taobao_orders" => {"$elemMatch" => {"cs_memo" => words}}}]}) if words
            elsif key == "has_unusual_state"
              search_tags_hash.update(Hash[key.to_sym, true])
              search_tags_hash.update({"$or" => [{"unusual_states" => {"$elemMatch" => {"reason" => words}}},{"note" => words}]}) if words
            elsif key == "has_seller_memo"
              search_tags_hash.update({"seller_memo" => not_void})
              search_tags_hash.update({"seller_memo" => words}) if words
            elsif key == "has_invoice_info"
              search_tags_hash.update({"$or" => [{"invoice_name" => not_void},{"invoice_type" => not_void},{"invoice_content" => not_void}]})
              search_tags_hash.update({"$or" => [{"invoice_name" => words}, {"invoice_type" => words}, {"invoice_content" => words}]}) if words
            elsif key == "has_product_info"
              search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"title" => not_void}}})
              search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"title" => words}}}) if words
            elsif key == "has_gift_memo"
              search_tags_hash.update({"$or" => [{"trade_gifts" => {"$elemMatch" => {"gift_title" => not_void}}},{"gift_memo" => not_void}]})
              search_tags_hash.update({"$or" => [{"trade_gifts" => {"$elemMatch" => {"gift_title" => words}}},{"gift_memo" => words}]}) if words
            else
              search_tags_hash.update({value_array[0] => not_void})
              search_tags_hash.update({value_array[0] => words}) if words
            end
          elsif value_array[1] == "false"
            void = {"$in" => ['', nil]}
            if key == "has_cs_memo" || key == "has_color_info" || key == "has_unusual_state"
              search_tags_hash.update(Hash[key.to_sym, false])
            elsif key == "has_seller_memo"
              search_tags_hash.update({"$and" => [{value_array[0] => void}, {"supplier_memo" => void}]})
            elsif key == "has_invoice_info"
              search_tags_hash.update({"$and" => [{"invoice_name" => void},{"invoice_type" => void},{"invoice_content" => void}]})
            elsif key == "has_product_info"
              search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"title" => void}}})
            elsif key == "has_gift_memo"
              search_tags_hash.update({"trade_gifts" => {"$elemMatch" => {"gift_title" => void}}})
              search_tags_hash.update({"gift_memo" => void})
            else
              search_tags_hash.update({value_array[0] => void})
            end
          end
        end
      end
    end

    # 集中筛选
    search_hash = {"$and" => [search_tags_hash,area_search_hash].compact}
    search_hash == {"$and"=>[]} ? search_hash = nil : search_hash
    ## 过滤有留言但还在抓取 + 总筛选
    trades.where(search_hash).and(trade_type_hash, {"$or" => [{"has_buyer_message" => {"$ne" => true}},{"buyer_message" => {"$ne" => nil}}]})
    ###筛选结束###
  end

  private
    def check_associate_deliver_bills
      DeliverBill.where(trade_id: self._id).delete_all if self.deleted_at != nil
    end

    def set_has_color_info
      self.orders.each do |order|
        colors = order.color_num.blank? ? [] : order.color_num
        if colors.is_a?(Array) && colors.flatten.select{|elem| elem.present?}.any?
          self.has_color_info = true
          return
        end
      end
      self.has_color_info = false
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

    def set_has_unusual_state
      if unusual_states.where(:repaired_at => nil).exists?
        self.has_unusual_state = true
        return
      else
        self.has_unusual_state = false
        true
      end
    end

    def set_has_onsite_service
      self.area_id = default_area.try(:id)
      if OnsiteServiceArea.where(area_id: default_area.id, account_id: account_id).present?
        self.has_onsite_service = true
      else
        self.has_onsite_service = false
      end
    end
end
