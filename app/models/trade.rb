# encoding: utf-8

class Trade
  include Mongoid::Document
  # Mongoid 4.0.0版本中移除了Paranoia，Versioning
  # 现在这是两个独立的gem包，升级Mongoid的时候请注意添加
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include MagicEnum
  include TradeMerge

  field :trade_source_id, type: Integer

  field :account_id, type: Integer
  field :seller_id, type: Integer
  field :forecast_seller_id, type: Integer                 #预测发货经销商
  field :seller_alipay_no, type: String
  field :seller_mobile, type: String
  field :seller_phone, type: String
  field :seller_name, type: String
  field :seller_email, type: String

  field :dispatched_at, type: DateTime                    # 分派时间
  field :delivered_at, type: DateTime                     # 发货时间

  field :cs_memo, type: String                            # 客服备注
  field :logistic_memo, type: String                      # 物流公司备注
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
  field :service_logistic_id, type:Integer                # 服务商物流ID(比如淘宝 京东 一号店等)

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
  field :seller_memo, type:String

  field :has_color_info, type: Boolean, default: false
  field :has_cs_memo, type: Boolean, default: false
  field :has_unusual_state, type: Boolean, default: false
  field :has_onsite_service, type: Boolean, default: false
  field :has_refund_orders, type: Boolean, default: false
  field :has_invoice_info, type: Boolean, default: false
  field :auto_merged_once, type: Boolean, default: false


  field :num, type: Integer
  field :num_iid, type: String
  field :title, type: String
  field :type, type: String

  field :buyer_message, type: String

  field :price, type: Float, default: 0.0
  field :seller_cod_fee, type: Float, default: 0.0
  field :discount_fee, type: Float, default: 0.0
  field :point_fee, type: Float, default: 0.0
  field :has_post_fee, type: Float, default: 0.0
  field :total_fee, type: Float, default: 0.0
  field :promotion_fee, type: Float, default: 0.0
  field :modify_payment, type: Float, default: 0.0

  field :is_lgtype, type: Boolean
  field :is_brand_sale, type: Boolean
  field :is_force_wlb, type: Boolean

  field :created, type: DateTime
  field :pay_time, type: DateTime
  field :modified, type: DateTime
  field :end_time, type: DateTime

  field :alipay_id, type: String
  field :alipay_no, type: String
  field :alipay_url, type: String
  field :buyer_memo, type: String
  field :buyer_flag, type: Integer

  field :seller_flag, type: Integer
  field :invoice_name, type: String
  field :buyer_nick, type: String
  field :buyer_area, type: String
  field :buyer_email, type: String

  field :has_yfx, type: Boolean
  field :yfx_fee, type: Float, default: 0.0
  field :yfx_id, type: String
  field :has_buyer_message, type: Boolean
  field :area_id, type: Integer
  field :credit_card_fee, type: Float, default: 0.0
  field :nut_feature, type: String
  field :shipping_type, type: String
  field :buyer_cod_fee, type: Float, default: 0.0
  field :express_agency_fee, type: Float, default: 0.0
  field :adjust_fee, type: Float
  field :buyer_obtain_point_fee, type: Float, default: 0.0
  field :cod_fee, type: Float, default: 0.0
  field :trade_from, type: String
  field :alipay_warn_msg, type: String
  field :cod_status, type: String
  field :can_rate, type: Boolean
  field :has_sent_send_logistic_rate_sms, type: Boolean
  field :commission_fee, type: Float, default: 0.0
  field :trade_memo, type: String
  field :seller_nick, type: String
  field :pic_path, type: String
  field :payment, type: Float, default: 0.0
  field :snapshot_url, type: String
  field :snapshot, type: String
  field :seller_rate, type: Boolean
  field :buyer_rate, type: Boolean
  field :real_point_fee, type: Integer
  field :post_fee, type: Float, default: 0.0
  field :buyer_alipay_no, type: String
  field :receiver_name, type: String
  field :receiver_state, type: String
  field :receiver_city, type: String
  field :receiver_district, type: String
  field :receiver_address, type: String
  field :receiver_zip, type: String
  field :receiver_mobile, type: String
  field :receiver_phone, type: String
  field :consign_time, type: DateTime
  field :available_confirm_fee, type: Float, default: 0.0
  field :received_payment, type: Float, default: 0.0
  field :timeout_action_time, type: DateTime
  field :is_3D, type: Boolean
  field :promotion, type: String
  field :got_promotion, type: Boolean, default: false  # 优惠信息是否抓到。
  field :sku_properties_name, type: String
  field :is_auto_dispatch, type: Boolean, default: false
  field :is_auto_deliver, type: Boolean, default: false


  #订单操作人
  field :operator_id
  field :operator_name

  #订单合并
  field :merged_trade_ids, type: Array
  field :merged_by_trade_id, type: String
  field :mergeable_id, type: String

  #人工订单锁定
  field :is_locked, type: Boolean, default: false

  # ADD INDEXES TO SPEED UP
  # 简单搜索index
  index tid: -1
  index buyer_nick: 1
  index receiver_name: 1
  index receiver_mobile: 1
  index seller_id: 1
  index logistic_name: 1
  index logistic_waybill: -1
  index logistic_code: 1

  # 时间搜索index
  index created: -1
  index pay_time: -1
  index reach_account_at: -1
  index dispatched_at: -1
  index delivered_at: -1
  index consign_time: -1
  index end_time: -1
  index deleted_at: -1
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

  #ID index
  index account_id: 1
  index trade_source_id: 1
  index merged_by_trade_id: 1
  index mergeable_id: 1
  index operator_id: 1
  index logistic_id: 1


  # 状态搜索index
  index status: 1
  # index splitted: -1
  # index splitted_tid: -1

  # 信息搜索index
  # index has_color_info: 1
  # index has_cs_memo: 1
  # index has_unusual_state: 1
  # index has_onsite_service: 1
  # index has_buyer_message: 1

  # 来源搜索index
  index _type: 1

  # 区域搜索index
  index receiver_state: 1
  index receiver_district: 1
  index receiver_city: 1

  #子文档搜索
  index "unusual_states.repair_man" => 1
  index "unusual_states.repaired_at" => -1
  index "unusual_states.key" => 1
  index "unusual_states.reason" => 1
  index "unusual_states.note" => 1
  index "trade_gifts.gift_title" => 1
  index "trade_gifts.gift_memo" => 1
  index "taobao_orders.title" => 1

  embeds_many :unusual_states
  embeds_many :operation_logs
  embeds_many :ref_batches
  embeds_many :manual_sms_or_emails
  embeds_many :trade_gifts
  embeds_many :taobao_orders
  embeds_many :promotion_details

  has_many :deliver_bills

  has_many :stock_out_bills

  belongs_to :customer, :class_name => "Customer", :foreign_key => "buyer_nick",:primary_key => "name"

  attr_accessor :matched_seller

  validate :color_num_do_not_exist, :on => :update, :if => :color_num_changed?
  validates_uniqueness_of :tid, scope: :_type, message: "操作频率过大，请重试"

  before_update :set_has_color_info
  before_update :set_has_cs_memo
  before_update :set_has_unusual_state
  before_update :set_has_refund_orders
  after_destroy :check_associate_deliver_bills


  scope  :paid_undispatched, ->{where({status:"WAIT_SELLER_SEND_GOODS", dispatched_at:nil})}
  # scope  :unmerged, ->{where(merged_by_trade_id:nil)}
  scope  :be_merged, ->{where({merged_by_trade_id:{"$ne"=>nil}})}
  scope  :is_merger, ->{where({merged_trade_ids:{"$ne"=>nil}})}

  # Trade.time_range_with_account(1,Time.now)
  # selector: {"account_id"=>1, "created"=>{"$gte"=>2013-07-16 16:00:00 UTC, "$lte"=>2013-07-17 15:59:59 UTC}}
  # ==
  # Trade.time_range_with_account(1,Time.now.ago(2.days),Time.now)
  # selector: {"account_id"=>1, "created"=>{"$gte"=>2013-07-14 16:00:00 UTC, "$lte"=>2013-07-17 15:59:59 UTC}}

  scope :time_range_with_account, ->(account_id,start_date,end_date=nil){
    start_date = start_date.to_time(:local) if start_date.is_a?(String)
    time_range = if end_date.blank?
      start_date.beginning_of_day..start_date.end_of_day
    else
      end_date = end_date.to_time(:local) if end_date.is_a?(String)
      start_date.beginning_of_day..end_date.end_of_day
    end
    where(account_id: account_id).between(created: time_range)
  }

  StatusHash = {
    "wait_pay_array"               => ["WAIT_BUYER_PAY",
                                       "ORDER_WAIT_PAY"],
    "paid_not_deliver_array"       => ["WAIT_SELLER_SEND_GOODS",
                                       "WAIT_SELLER_DELIVERY",
                                       "WAIT_SELLER_STOCK_OUT",
                                       "ORDER_PAYED",
                                       "ORDER_TRUNED_TO_DO"],
    "paid_and_delivered_array"     => ["WAIT_BUYER_CONFIRM_GOODS",
                                       "WAIT_GOODS_RECEIVE_CONFIRM",
                                       "WAIT_BUYER_CONFIRM_GOODS_ACOUNTED",
                                       "WAIT_SELLER_SEND_GOODS_ACOUNTED",
                                       "ORDER_CAN_OUT_OF_WH",
                                       "ORDER_OUT_OF_WH",
                                       "ORDER_SENDED_TO_LOGITSIC",
                                       "ORDER_RECEIVED"],
    "closed_array"                 => ["TRADE_CLOSED",
                                       "TRADE_CANCELED",
                                       "TRADE_CLOSED_BY_TAOBAO",
                                       "ALL_CLOSED",
                                       "ORDER_CANCEL"],
    "succeed_array"                => ["TRADE_FINISHED",
                                       "FINISHED_L",
                                       "ORDER_FINISH"],
    # contains TaobaoOrder and SubPurchaseOrder
    "taobao_trade_refund_array"    => ["WAIT_SELLER_AGREE",
                                       "SELLER_REFUSE_BUYER",
                                       "WAIT_BUYER_RETURN_GOODS",
                                       "WAIT_SELLER_CONFIRM_GOODS",
                                       "CLOSED",
                                       "SUCCESS"],
    "taobao_purchase_refund_array" => ['TRADE_REFUNDED',
                                       'TRADE_REFUNDING']
  }.freeze


  def fetch_account
    return Account.find(self.account_id) if self.account_id_change
    @account ||= Account.find(self.account_id)
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
    local_sku_id = (value['sku_id'].to_i == 0 ? nil : value['sku_id'].to_i)
    sku = Sku.find_by_id(local_sku_id)
    gift_product = Product.find_by_id(value['product_id'].to_i)
    self.taobao_orders.create!(_type: "TaobaoOrder",
                               oid: self.tid,
                               status: "WAIT_SELLER_SEND_GOODS",
                               title: value['gift_title'].try(:gsub, '标准款', ''),
                               price: 0,
                               total_fee: 0,
                               payment: 0,
                               discount_fee: 0,
                               outer_iid: gift_product.outer_id,
                               adjust_fee: 0,
                               num_iid: gift_product.num_iid,
                               sku_id:  sku.try(:sku_id),  # this should be skus.sku_id not skus.id, and its' type is string not integer.
                               local_sku_id:  local_sku_id, # this should be skus.id, and its' type is integer.
                               num: value['num'].to_i,
                               pic_path: gift_product.pic_url,
                               refund_status: "NO_REFUND",
                               cid: gift_product.cid,
                               order_gift_tid: value['gift_tid'])
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

  def last_unusual_state
    unusual_states.where(repaired_at: nil).last.try(:reason)
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

  ['add_ref', 'return_ref', 'refund_ref'].each do |ref_method|
    define_method(ref_method.to_sym) do
      ref_batches.where(ref_type: ref_method).last
    end

    define_method((ref_method+'_status').to_sym) do
      self.send(ref_method.to_sym).operation_text if self.send(ref_method.to_sym).present?
    end
  end

  def stock_out_bill # always should be the only active one
    stock_out_bills.where(:status.ne => "CLOSED").first
  end

  def reset_seller
    return unless seller_id
    stock_out_bills.where(:status.ne => "CLOSED").each do |bill|
      if bill.do_close #关闭之前的出库单
        bill.increase_activity #恢复仓库的可用库存
      else
        next #已出库或者已同步 不允许分流重置
      end
    end
    update_attributes(seller_id: nil, seller_name: nil, dispatched_at: nil)
    deliver_bills.delete_all
  end

  def seller(sid = seller_id)
    Seller.find_by_id sid
  end

  def default_seller(area = nil)
    if _type == "JingdongTrade"
      Seller.find_by_id(self.fetch_account.settings.default_jingdong_seller_id)
    elsif _type == "YihaodianTrade"
      Seller.find_by_id(self.fetch_account.settings.default_yihaodian_seller_id)
    else
      area ||= default_area
      area.sellers.where(active: true, account_id: account_id).first
    end
  end

  def matched_seller_with_default(area)
    matched_seller(area) || default_seller(area)
  end

  def matched_seller(area = nil)
    area ||= default_area
    @matched_seller ||= SellerMatcher.match_trade_seller(self.id, area)
  end

  def matched_logistics
    area = default_area
    if area
      @logistic_ids = LogisticArea.where(area_id: area.id).map{|l| l.logistic_id }.join(",")
      @matched_logistics = Logistic.where("id in (?)", @logistic_ids).map{|ml| [ml.id, ml.name, "/logistics/#{ml.id}/print_flash_settings/#{ml.print_flash_setting.id}/print_infos.xml"]}
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
    stock_out_bills.where(:status.ne => "CLOSED").each do |bill|
      if bill.do_close #关闭之前的出库单
        bill.increase_activity #恢复仓库的可用库存
      else
        next #已出库或者已同步 不允许生成新的出库单
      end
    end

    if _type == "TaobaoTrade"
      remark = "客服备注: #{cs_memo} 卖家备注: #{seller_memo} 客户留言:#{buyer_message}"
    else
      remark = cs_memo
    end

    bill = stock_out_bills.new(op_state:receiver_state,
                               op_city: receiver_city,
                               op_district: receiver_district,
                               op_address: receiver_address,
                               status: 'CHECKED',
                               op_name: receiver_name,
                               op_mobile: receiver_mobile,
                               op_zip: receiver_zip,
                               op_phone: receiver_phone,
                               logistic_id: logistic_id,
                               remark: remark,
                               website: invoice_name,
                               is_cash_sale: invoice_type,
                               stock_typs: "CM",
                               account_id: account_id,
                               checked_at: Time.now,
                               created_at: Time.now,
                               seller_id: seller_id)

    if splitted
      bill.tid = splitted_tid
    else
      bill.tid = tid
    end

    regular_orders = orders.where(refund_status: 'NO_REFUND')

    regular_orders.each do |order|
      order_num = order.num
      if order.sku_bindings.present?
        order.sku_bindings.each do |binding|
          sku_id = binding.sku_id
          sku = Sku.find_by_id(binding.sku_id)
          product = sku.try(:product)
          if product
            binding_number = binding.number * order_num
            stock_product = fetch_account.stock_products.where(seller_id: seller_id, product_id: product.id, sku_id: sku_id).first
            order_price = (order.price == 0 ? 0 : product.price)
            if stock_product
              bill.bill_products.build(
                stock_product_id: stock_product.id,
                title: sku.title,
                outer_id: product.outer_id,
                sku_id: sku_id,
                price: order_price,
                total_price: order_price * binding_number,
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
      elsif order.local_skus.present?
        order.local_skus.each do |sku|
          sku_id = sku.id
          sku = Sku.find_by_id(sku_id)
          product = sku.try(:product)
          if product
            stock_product = fetch_account.stock_products.where(seller_id: seller_id, product_id: product.id, sku_id: sku_id).first
            order_price = (order.price == 0 ? 0 : product.price)
            if stock_product
              bill.bill_products.build(
                stock_product_id: stock_product.id,
                title: sku.title,
                outer_id: product.outer_id,
                sku_id: sku_id,
                price: order_price,
                total_price: product.price * order_num,
                number: order_num,
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
    bill.bill_products_price = regular_orders.sum(:payment) - self.post_fee
    bill.save!
    bill.decrease_activity #减去仓库的可用库存
  end

  # SKU属性不全
  def generate_deliver_bill
    return if _type == 'JingdongTrade'
    #分派时生成默认发货单, 不支持京东订单
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
            if bill_product
              bill_product.number += 1
              bill_product.save
            else
              bill.bill_products.create(title: title, outer_id: outer_iid, num_iid: num_iid, sku_id: sku_id, sku_name: sku_name, colors: order.color_num,number: 1, memo: order.cs_memo)
            end
          end
        end
      end
    else
      bill = deliver_bills.create(deliver_bill_number: "#{tid}01", seller_id: seller_id, seller_name: seller_name, account_id: account_id)
      orders.each do |order|
        taobao_sku = order.taobao_sku || order.local_skus.first
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

  ## 发货相关

  def deliverable?
    trades = Trade.where(tid: tid).select do |trade|
      trade.orders.where(:refund_status.in => ['NO_REFUND', 'CLOSED']).size != 0
    end
    (trades.map(&:status) - ["WAIT_BUYER_CONFIRM_GOODS"]).size == 0 && !trades.map(&:delivered_at).include?(nil)
  end

  def deliver!
    return unless self.deliverable?
    TradeDeliver.perform_async(self.id)
  end

  def auto_deliver!
    result = self.fetch_account.can_auto_deliver_right_now
    TradeAutoDeliver.perform_in((result == true ? self.fetch_account.settings.auto_settings['deliver_silent_gap'].to_i.hours : result), self.id)
    self.is_auto_deliver = true
    self.operation_logs.create(operated_at: Time.now, operation: "自动发货")
    self.save
  end

  ## 分流相关

  def dispatchable?
    seller_id.blank? && is_paid_not_delivered
  end

  def dispatch!(seller = nil)
    return false unless dispatchable?

    seller ||= matched_seller

    return false if seller.blank?

    # 更新订单状态为已分派
    update_attributes(seller_id: seller.id, seller_name: seller.name, dispatched_at: Time.now)

    update_attributes!(seller_id: seller.id, seller_name: seller.name, dispatched_at: Time.now)
    # 如果满足自动化设置条件，分派后订单自动发货
    auto_settings = self.fetch_account.settings.auto_settings
    if auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "dispatched_trade"
      auto_deliver!
    end

    # 生成默认发货单
    generate_deliver_bill
    generate_stock_out_bill
  end

  def auto_dispatchable?
    if !fetch_account || !fetch_account.settings.auto_settings || !self.fetch_account.settings.auto_settings["dispatch_conditions"]
      can_auto_dispatch = false
    else
      dispatch_conditions = self.fetch_account.settings.auto_settings["dispatch_conditions"]
      void_buyer_message = (dispatch_conditions["void_buyer_message"].present? ? false : true) || !has_buyer_message
      void_seller_memo = (dispatch_conditions["void_seller_memo"].present? ? false : true) || seller_memo.blank?
      void_cs_memo = (dispatch_conditions["void_cs_memo"].present? ? false : true) || !has_cs_memo
      void_money = (dispatch_conditions["void_money"].present? ? false : true) || !has_refund_orders
      can_auto_dispatch = void_buyer_message && void_seller_memo && void_cs_memo && void_money
    end
    can_auto_dispatch && dispatchable?
  end

  def auto_dispatch!
    return false unless auto_dispatchable?
    dispatch!
    self.is_auto_dispatch = true
    if self.save
      self.operation_logs.create(operated_at: Time.now, operation: "自动分派")
    end
  end

  ## model属性方法 ##

  def out_iids
    self.orders.map {|o| o.outer_iid}
  end

  def receiver_address_array
    # 请按照 省市区 的顺序生成array
    [self.receiver_state, self.receiver_city, self.receiver_district]
  end

  def taobao_status_memo
    case status
    when "TRADE_NO_CREATE_PAY"
      "没有创建支付宝交易"
    when "WAIT_BUYER_PAY"
      "等待付款"
    when "WAIT_SELLER_SEND_GOODS"
      "已付款，待发货"
    when "WAIT_BUYER_CONFIRM_GOODS"
      "已付款，已发货"
    when "TRADE_BUYER_SIGNED"
      "买家已签收,货到付款专用"
    when "TRADE_FINISHED"
      "交易成功"
    when "TRADE_CLOSED"
      "交易已关闭"
    when "TRADE_CLOSED_BY_TAOBAO"
      "交易被淘宝关闭"
    when "ALL_WAIT_PAY"
      "包含：等待买家付款、没有创建支付宝交易"
    when "ALL_CLOSED"
      "包含：交易关闭、交易被淘宝关闭"
    else
      status
    end
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
    when 'YihaodianTrade'
      yihaodian_trade_tids = $redis.smembers 'YihaodianTradeTids'
      yihaodian_trade_tids.each do |tid|
        $redis.srem('YihaodianTradeTids', tid)
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
  def self.filter(current_account, current_user, params, type="scoped")

    if type == "unscoped"
      trades = Trade.unscoped.where(is_locked: false)
    else
      trades = Trade
    end

    if params[:trade_type] && params[:trade_type] == "locked"
      trades = trades.deleted.where(account_id: current_account.id)
    else
      trades = trades.where(account_id: current_account.id)
    end

    if current_user.seller.present?
      seller = current_user.seller
      self_and_descendants_ids = seller.self_and_descendants.map(&:id)
      trades = trades.any_in(seller_id: self_and_descendants_ids) if self_and_descendants_ids.present?
    end

    if current_user.logistic.present?
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

      # 异常订单
      auto_unusual = current_account.settings.auto_settings["auto_mark_unusual_trade"]
      unusual_auto_setting = current_account.settings.auto_settings["unusual_conditions"]
      if auto_unusual && unusual_auto_setting
        if ['unpaid_for_days', 'undispatched_for_days', 'undelivered_for_days', 'unreceived_for_days', 'unrepaired_for_days'].include?(type)
          state = type.split("_")[0]
          day_num = unusual_auto_setting["max_"+state+"_days"]
          trade_type_hash = {:unusual_states.elem_match => {key: "#{state}_in_#{day_num}_days", :repaired_at => nil}}
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
        trade_type_hash = {:unusual_states.elem_match =>{:repaired_at => nil}}
      when 'my_trade'
        trade_type_hash = {:operator_id => current_user.id}
      when 'all'
        trade_type_hash = nil
      when 'dispatched'
        trade_type_hash = {:dispatched_at.ne => nil, :status.in => StatusHash["paid_not_deliver_array"] + StatusHash["paid_and_delivered_array"]}
      when 'undispatched'
        trade_type_hash = {:status.in => StatusHash["paid_not_deliver_array"], seller_id: nil, has_unusual_state: false, :pay_time.ne => nil}
      when 'unpaid'
        trade_type_hash = {:status.in => StatusHash['wait_pay_array']}
      when 'paid'
        trade_type_hash = {:status.in => StatusHash["paid_not_deliver_array"] + StatusHash["paid_not_deliver_array"] + StatusHash["succeed_array"]}
      when 'undelivered','seller_undelivered'
        trade_type_hash = {:dispatched_at.ne => nil, :status.in => StatusHash["paid_not_deliver_array"], has_unusual_state: false}
      when 'delivered','seller_delivered'
        trade_type_hash = {:status.in => StatusHash["paid_and_delivered_array"], has_unusual_state: false}
      when 'refund'
        trade_type_hash = {"$or" => [{ :"taobao_orders.refund_status" => {:'$in' => StatusHash["taobao_trade_refund_array"]}}, {:"taobao_sub_purchase_orders.status" => {:'$in' => StatusHash["taobao_purchase_refund_array"]}}]}
      when 'return'
        trade_type_hash = {:request_return_at.ne => nil}
      when 'closed'
        trade_type_hash = {:status.in => StatusHash["closed_array"]}
      when 'unusual_trade'
        trade_type_hash = {status: "TRADE_NO_CREATE_PAY"}
      when 'deliver_unconfirmed'
        trade_type_hash = {seller_confirm_deliver_at: nil, :status.in => StatusHash["paid_and_delivered_array"]}

      # # 发票
      # when 'invoice_all'
      #   trade_type_hash = {:invoice_name.ne => nil}
      # when 'invoice_unfilled'
      #   trade_type_hash = {seller_confirm_invoice_at: nil}
      # when 'invoice_filled'
      #   trade_type_hash = {:seller_confirm_invoice_at.ne => nil}
      # when 'invoice_sent'
      #   trade_type_hash = {:status.in => StatusHash["paid_and_delivered_array"], :seller_confirm_invoice_at.ne => nil}

      # 退货
      when 'request_return'
        trade_type_hash = {:request_return_at.ne => nil, confirm_return_at: nil}
      when 'confirm_return'
        trade_type_hash = {:confirm_return_at.ne => nil}

      # 调色
      when "color_unmatched"
        trade_type_hash = {has_color_info: false, :status.in => StatusHash["paid_not_deliver_array"]}
      when "color_matched"
        trade_type_hash = {has_color_info: true, :status.in => StatusHash["paid_not_deliver_array"], confirm_color_at: nil}
      when "color_confirmed"
        trade_type_hash = {has_color_info: true, :status.in => StatusHash["paid_not_deliver_array"], :confirm_color_at.ne => nil}

      # 锁定
      when 'locked'
        trade_type_hash = {is_locked: true}

      # 登录时的默认显示
      when "default"
        # 经销商登录默认显示未发货订单
        if current_user.seller.present?
          trades = trades.where(:dispatched_at.ne => nil, :status.in => StatusHash["paid_not_deliver_array"])
        else
        # 管理员，客服登录默认显示未分派淘宝订单
        # if current_user.has_role?(:cs) || current_user.has_role?(:admin)
          trades = trades.where(:status.in => StatusHash["paid_not_deliver_array"], seller_id: nil).where(_type: 'TaobaoTrade')
        end
      end
    end

    conditions = {}
    ## 筛选
    if params[:search]

      search_tags_hash = {}
      area_search_hash = {}
      params[:search].each do |key,values|

        conditions[key] ||= []

        values = [values] if !values.is_a? Array

        values.each{|value|
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
                conditions[key] << {"seller_id" => {"$in" => seller_ids}}
              elsif key == 'receiver_name'
                search_tags_hash.update({"$or" => [{receiver_name: regexp_value}, {"consignee_info.fullname" => regexp_value}, {"receiver.name" => regexp_value}]})
                conditions[key] << {"$or" => [{receiver_name: regexp_value}, {"consignee_info.fullname" => regexp_value}, {"receiver.name" => regexp_value}]}
              elsif key == 'receiver_mobile'
                search_tags_hash.update({"$or" => [{receiver_mobile: regexp_value}, {"consignee_info.mobile" => regexp_value}, {"receiver.mobile_phone" => regexp_value}]})
                conditions[key] << {"$or" => [{receiver_mobile: regexp_value}, {"consignee_info.mobile" => regexp_value}, {"receiver.mobile_phone" => regexp_value}]}
              elsif key == 'repair_man'
                search_tags_hash.update({"unusual_states" =>{"$elemMatch" => {"repair_man" => regexp_value}}})
                conditions[key] << {"unusual_states" =>{"$elemMatch" => {"repair_man" => regexp_value}}}
              elsif key == '_type'
                values = value.split("-")
                search_tags_hash.update({"_type" => values[0], "custom_type" => values[1]})
                conditions[key] << {"_type" => values[0], "custom_type" => values[1]}
              elsif key == 'merge_type'
                if value == 'merged'
                  search_tags_hash.update({:merged_trade_ids=> {"$ne"=>nil}})
                  conditions[key] << {:merged_trade_ids=> {"$ne"=>nil}}
                elsif value == 'mergeable'
                  search_tags_hash.update({:mergeable_id=> {"$ne"=>nil}})
                  conditions[key] << {:mergeable_id=> {"$ne"=>nil}}
                elsif value == 'export_merged'
                  search_tags_hash.update({:merged_by_trade_id=> {"$ne"=>nil}})
                  conditions[key] << {:merged_by_trade_id=> {"$ne"=>nil}}
                end
              elsif key == "print_at"
                if value == 'un_deliver_bill_printed_at'
                  search_tags_hash.update({deliver_bill_printed_at: nil})
                  conditions[key] << {deliver_bill_printed_at: nil}
                elsif value == 'deliver_bills_print_at'
                  search_tags_hash.update({:deliver_bill_printed_at => {"$ne"=>nil} })
                  conditions[key] << {:deliver_bill_printed_at => {"$ne"=>nil} }
                end
              elsif key == "logistics_print_at"
                if value == "un_logistics_bill_printed_at"
                  search_tags_hash.update({:logistic_printed_at=> nil })
                  conditions[key] << {:logistic_printed_at=> nil }
                elsif value == "logistics_bill_printed_at"
                  search_tags_hash.update({:logistic_printed_at => {"$ne"=>nil} })
                  conditions[key] << {:logistic_printed_at => {"$ne"=>nil}  }
                end
              else
                search_tags_hash.update(Hash[key.to_sym, value])
                conditions[key] << Hash[key.to_sym, value]
              end
            end

          # 状态筛选＋时间筛选＋金额筛选
          when 2
            if value_array[1] == "true" || value_array[1] == "false"
              if value_array[0].present?
                status_array = value_array[0].split(",")
                search_tags_hash.update({key =>{"$in" => status_array}})
                conditions[key] << {key =>{"$in" => status_array}}
              end
            else
              if value_array[0].present? && value_array[1].present?
                if value_array[0].include?('-')
                  start_time = value_array[0].to_time(:local)
                  end_time = value_array[1].to_time(:local)
                  if key == "reach_account_at"
                    trades = trades.where(status: 'TRADE_FINISHED')
                    conditions[key] << {:end_time => {"$gte" => start_time, "$lt" => end_time}}
                    search_tags_hash.update({:end_time => {"$gte" => start_time, "$lt" => end_time}})
                  else
                    search_tags_hash.update({key => {"$gte" => start_time, "$lt" => end_time}})
                    conditions[key] << {key => {"$gte" => start_time, "$lt" => end_time}}
                  end
                else
                  min_money = value_array[0].to_f
                  max_money = value_array[1].to_f
                  search_tags_hash.update({key => {"$gte" => min_money, "$lt" => max_money}})
                  conditions[key] << {key => {"$gte" => min_money, "$lt" => max_money}}
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
            conditions[key] << area_search_hash

          # 信息筛选
          when 4
            and_cond = []
            words = (value_array[3] == "true" ? /#{value_array[2]}/ : /^[^#{value_array[2]}]+$/) if value_array[2].present?
            if value_array[1] == "true"
              not_void = {"$nin" => ['', nil]}
              if key == "has_color_info"
                search_tags_hash.update({"has_color_info" => true})
                search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"$and" => [{"color_num" => words},{"color_hexcode" => words},{"color_name" => words}]}}}) if words
                and_cond << {"has_color_info" => true}
                #and_cond = [Hash[key.to_sym, true]]
                and_cond << {"taobao_orders" => {"$elemMatch" => {"$and" => [{"color_num" => words},{"color_hexcode" => words},{"color_name" => words}]}}} if words
                conditions[key] << {"$and"=>and_cond}

              elsif key == "has_cs_memo"
                search_tags_hash.update({"has_cs_memo" => true})
                search_tags_hash.update({"$or" => [{"cs_memo" => words},{"taobao_orders" => {"$elemMatch" => {"cs_memo" => words}}}]}) if words

                and_cond << {"has_cs_memo" => true}
                and_cond << {"$or" => [{"cs_memo" => words},{"taobao_orders" => {"$elemMatch" => {"cs_memo" => words}}}]} if words
                conditions[key] << {"$and"=>and_cond}

              elsif key == "has_unusual_state"
                search_tags_hash.update({"has_unusual_state" => true})
                search_tags_hash.update({"$or" => [{"unusual_states" => {"$elemMatch" => {"reason" => words}}},{"note" => words}]}) if words
                and_cond << {"has_unusual_state" => true}
                and_cond << {"$or" => [{"unusual_states" => {"$elemMatch" => {"reason" => words}}},{"note" => words}]} if words
                conditions[key] << {"$and"=>and_cond}
              elsif key == "has_seller_memo"
                search_tags_hash.update({"seller_memo" => not_void})
                search_tags_hash.update({"seller_memo" => words}) if words
                and_cond << {"seller_memo" => not_void}
                and_cond << {"seller_memo" => words} if words

                conditions[key] << {"$and"=>and_cond}

              elsif key == "has_invoice_info"
                search_tags_hash.update({"$or" => [{"invoice_name" => not_void},{"invoice_type" => not_void},{"invoice_content" => not_void}]})
                search_tags_hash.update({"$or" => [{"invoice_name" => words}, {"invoice_type" => words}, {"invoice_content" => words}]}) if words
                and_cond << {"$or" => [{"invoice_name" => not_void},{"invoice_type" => not_void},{"invoice_content" => not_void}]}
                and_cond << {"$or" => [{"invoice_name" => words}, {"invoice_type" => words}, {"invoice_content" => words}]} if words
                conditions[key] << {"$and"=>and_cond}

              elsif key == "has_product_info"
                search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"title" => not_void}}})
                search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"title" => words}}}) if words
                and_cond << {"taobao_orders" => {"$elemMatch" => {"title" => not_void}}}
                and_cond << {"taobao_orders" => {"$elemMatch" => {"title" => words}}} if words
                conditions[key] << {"$and"=>and_cond}


              elsif key == "has_gift_memo"
                search_tags_hash.update({"$or" => [{"trade_gifts" => {"$elemMatch" => {"gift_title" => not_void}}},{"gift_memo" => not_void}]})
                search_tags_hash.update({"$or" => [{"trade_gifts" => {"$elemMatch" => {"gift_title" => words}}},{"gift_memo" => words}]}) if words
                and_cond << {"$or" => [{"trade_gifts" => {"$elemMatch" => {"gift_title" => not_void}}},{"gift_memo" => not_void}]}
                and_cond << {"$or" => [{"trade_gifts" => {"$elemMatch" => {"gift_title" => words}}},{"gift_memo" => words}]} if words

                conditions[key] << {"$and"=>and_cond}

              elsif key == "has_logistic_info"
                search_tags_hash.update({"$and" => [{"logistic_id" => not_void},{"logistic_waybill" => not_void}]})
                search_tags_hash.update({"$or" => [{"logistic_waybill" => words},{"logistic_name" => words},{"logistic_code" => words}]}) if words

                and_cond = [{"$and" => [{"logistic_id" => not_void},{"logistic_waybill" => not_void}]}]
                and_cond << {"$or" => [{"logistic_waybill" => words},{"logistic_name" => words},{"logistic_code" => words}]} if words
                conditions[key] << {"$and"=>and_cond}

              else
                search_tags_hash.update({value_array[0] => not_void})
                search_tags_hash.update({value_array[0] => words}) if words
                and_cond = {value_array[0] => not_void}
                and_cond = {value_array[0] => words} if words
                conditions[key] << {"$and"=>and_cond}

              end
            elsif value_array[1] == "false"
              void = {"$in" => ['', nil]}
              if key == "has_cs_memo" || key == "has_color_info" || key == "has_unusual_state"
                search_tags_hash.update(Hash[key.to_sym, false])
                conditions[key] << Hash[key.to_sym, false]
              elsif key == "has_seller_memo"
                search_tags_hash.update({"$and" => [{value_array[0] => void}, {"supplier_memo" => void}]})
                conditions[key] << {"$and" => [{value_array[0] => void}, {"supplier_memo" => void}]}
              elsif key == "has_invoice_info"
                search_tags_hash.update({"$and" => [{"invoice_name" => void},{"invoice_type" => void},{"invoice_content" => void}]})
                conditions[key] << {"$and" => [{"invoice_name" => void},{"invoice_type" => void},{"invoice_content" => void}]}
              elsif key == "has_product_info"
                search_tags_hash.update({"taobao_orders" => {"$elemMatch" => {"title" => void}}})
                conditions[key] << {"taobao_orders" => {"$elemMatch" => {"title" => void}}}
              elsif key == "has_gift_memo"
                search_tags_hash.update({"trade_gifts" => {"$elemMatch" => {"gift_title" => void}}})
                search_tags_hash.update({"gift_memo" => void})
                conditions[key] << {"trade_gifts" => {"$elemMatch" => {"gift_title" => void}}}
              elsif key == "has_logistic_info"
                search_tags_hash.update({"$or" => [{"logistic_id" => void},{"logistic_waybill" => void}]})
                conditions[key] << {"$or" => [{"logistic_id" => void},{"logistic_waybill" => void}]}
              else
                search_tags_hash.update({value_array[0] => void})
                conditions[key] << {value_array[0] => void}
              end
            end
          end

        }

      end
    end

    # 集中筛选
    #search_hash = {"$and" => [search_tags_hash,area_search_hash].compact}
    search_hash = {"$and"=> conditions.values.map{|value| {"$or"=>value.flatten}}}
    search_hash == {"$and"=>[]} ? search_hash = nil : search_hash
    ## 过滤有留言但还在抓取 + 总筛选
    trades.where(search_hash).and(trade_type_hash, {"$or" => [{"has_buyer_message" => {"$ne" => true}},{"buyer_message" => {"$ne" => nil}}]})
    ###筛选结束###
  end

  def set_has_onsite_service
    return unless fetch_account.settings.enable_module_onsite_service == 1
    self.area_id = default_area.try(:id)
    if OnsiteServiceArea.where(area_id: default_area.id, account_id: account_id).present?
      self.has_onsite_service = true
    else
      self.has_onsite_service = false
    end
  end

  def operators
    fetch_account.users.where(can_assign_trade: true).where(active: true).order(:created_at) rescue []
  end

  def operation_percent
    operators.inject(0) { |sum, el| sum += el.trade_percent.to_i }
  end

  def set_operator
    if operation_percent >= 1
      rand_number = rand(1..operation_percent)
      count = 0
      operators.each do |operator|
        percent = operator.trade_percent || 0
        if rand_number <= percent + count
          update_attributes(operator_id: operator.id, operator_name: operator.username)
          return
        else
          count += operator.trade_percent
        end
      end
    end
  end

  def type_text
    if self.custom_type.present?
      if self.custom_type == 'gift_trade'
        '赠品'
      elsif self.custom_type == 'handmade_trade'
        '人工'
      end
    elsif self._type == "TaobaoTrade"
      '淘宝'
    elsif self._type == "JingdongTrade"
      '京东'
    elsif self._type == "YihaodianTrade"
      '一号店'
    end
  end

  def orders
    self.taobao_orders
  end

  def orders=(new_orders)
    self.taobao_orders = new_orders
  end

  def orders_total_price
    self.orders.inject(0) { |sum, order| sum + order.price*order.num}
  end

  def vip_discount
    promotion_details.where(promotion_id: /^shopvip/i).sum(&:discount_fee)
  end

  def shop_bonus
    promotion_details.where(promotion_id: /^shopbonus/i).sum(&:discount_fee)
  end

  def shop_discount
    promotion_details.where(promotion_id: /^(?!shopvip|shopbonus)/i).sum(&:discount_fee)
  end

  def other_discount
    (total_fee + post_fee - payment - promotion_fee).to_f.round(2)
  end

  #判断订单状态
  def is_paid_not_delivered
    StatusHash['paid_not_deliver_array'].include?(status)
  end

  def is_paid_and_delivered
    StatusHash['paid_and_delivered_array'].include?(status)
  end

  def change_status_to_deliverd
    if self._type == "JingdongTrade"
      self.status = "WAIT_GOODS_RECEIVE_CONFIRM"
    elsif self._type == "YihaodianTrade"
      self.status = "ORDER_SENDED_TO_LOGITSIC"
    else
      self.status = "WAIT_BUYER_CONFIRM_GOODS"
    end
  end

  def is_succeeded
    StatusHash['succeed_array'].include?(status)
  end

  def is_closed
    StatusHash['closed_array'].include?(status)
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

    def set_has_refund_orders
      self.orders.each do |order|
        if order.refund_status != 'NO_REFUND'
          self.has_refund_orders = true
          return
        end
      end
      self.has_refund_orders = false
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
end