# -*- encoding:utf-8 -*-
class JingdongTrade < Trade

  #京东特有字段
  field :pay_type, type: String
  field :vender_id, type: String

  field :order_seller_price, type: Float   # 订单货款金额
  field :delivery_type, type: String       # 送货日期类型
  field :order_state_remark, type: String  # 中文状态
  field :return_order, type: String        # 换货订单标识
  field :pin, type: String                 # 买家账号信息

  #对应trade字段
  field :tid,               as: :order_id, type: String
  field :total_fee,         as: :order_total_price, type: Float, default: 0.0
  field :payment,           as: :order_payment, type: Float, default: 0.0
  field :post_fee,          as: :freight_price, type: Float, default: 0.0
  field :discount_fee,      as: :seller_discount, type: Float, default: 0.0

  field :status,            as: :order_state, type: String

  field :buyer_message,     as: :order_remark, type: String
  field :seller_memo,       as: :vender_remark, type: String
  field :invoice_type,      as: :invoice_info, type: String

  field :created,           as: :order_start_time, type: DateTime
  ## 京东订单无付款时间,目前以订单抓取时间为付款时间 ##
  field :pay_time
  field :consign_time,      as: :order_end_time, type: DateTime

  field :receiver_name,     as: :fullname, type: String
  field :receiver_address,  as: :full_address, type: String
  field :receiver_phone,    as: :telephone, type: String
  field :receiver_mobile,   as: :mobile, type: String
  field :receiver_state,    as: :province, type: String
  field :receiver_city,     as: :city, type: String
  field :receiver_district, as: :county, type: String

  embeds_many :jingdong_orders
  embeds_many :coupon_details


  enum_attr :status, [["等待出库"     ,"WAIT_SELLER_STOCK_OUT"],
                      ["等待确认收货"  ,"WAIT_GOODS_RECEIVE_CONFIRM"],
                      ["完成"         ,"FINISHED_L"],
                      ["取消"         ,"TRADE_CANCELED"],
                      ["已锁定"        ,"LOCKED"]],:not_valid => true

  def orders
    self.jingdong_orders
  end

  def orders=(new_orders)
    self.jingdong_orders = new_orders
  end

  ## 分派相关 ##
  def matched_seller(area = nil)
    area ||= default_area
    SellerMatcher.match_trade_seller(self, area)
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

  #PENDING NEED JINGDONG SKU
  def generate_deliver_bill
  end

  def deliverable?
    self.orders.where(:refund_status.in => ['NO_REFUND', 'CLOSED']).size != 0 &&
    self.is_paid_not_delivered &&
    self.delivered_at.blank?
  end

  def deliver!
    return unless self.deliverable?
    ## 执行SOP出库，接口已调整好，由于不知道现在是否需要，先不做这个操作
    # TradeJingdongDeliver.perform_async(self.id)
  end

  #PENDING NEED ADAPTION
  # def invoice_name
  #   unless self.invoice_info.present?
  #     self.invoice_name = self.invoice_info.split(";")[1]
  #     self.save
  #   end
  #   self.invoice_name
  # end

  def auto_deliver!
    #PENDING
  end

  def jingdong_status_memo
  end

  #PENDING
  # def total_fee
  #   order_seller_price.to_f + post_fee.to_f - seller_discount.to_f
  # end

  def status=(status)
    case status
    when 'WAIT_BUYER_CONFIRM_GOODS'
      self[:status] = 'WAIT_GOODS_RECEIVE_CONFIRM'
    else
      super status
    end
  end

  def set_has_onsite_service
    self.has_onsite_service = false
  end

  def vip_discount
    0
  end

  def shop_bonus
    0
  end

  def shop_discount
    0
  end

  def other_discount
    0
  end
end