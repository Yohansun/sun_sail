# -*- encoding : utf-8 -*-

class TaobaoTrade < Trade
  include StockProductsLockable
  #include Dulux::Splitter

  field :tid, type: String
  field :num, type: Integer
  field :num_iid, type: String
  field :status, type: String
  field :title, type: String
  field :type, type: String

  field :seller_memo, type: String
  field :buyer_message, type: String

  field :price, type: Float
  field :seller_cod_fee, type: Float
  field :discount_fee, type: Float, default: 0.0
  field :point_fee, type: Float
  field :has_post_fee, type: Float
  field :total_fee, type: Float

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
  field :yfx_fee, type: Float
  field :yfx_id, type: String
  field :has_buyer_message, type: Boolean
  field :area_id, type: Integer
  field :credit_card_fee, type: Float
  field :nut_feature, type: String
  field :shipping_type, type: String
  field :buyer_cod_fee, type: Float
  field :express_agency_fee, type: Float
  field :adjust_fee, type: Float
  field :buyer_obtain_point_fee, type: Float
  field :cod_fee, type: Float
  field :trade_from, type: String
  field :alipay_warn_msg, type: String
  field :cod_status, type: String
  field :can_rate, type: Boolean
  field :has_sent_send_logistic_rate_sms, type: Boolean
  field :commission_fee, type: Float
  field :trade_memo, type: String
  field :seller_nick, type: String
  field :pic_path, type: String
  field :payment, type: Float
  field :snapshot_url, type: String
  field :snapshot, type: String
  field :seller_rate, type: Boolean
  field :buyer_rate, type: Boolean
  field :real_point_fee, type: Integer
  field :post_fee, type: Float
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
  field :available_confirm_fee, type: Float
  field :received_payment, type: Float
  field :timeout_action_time, type: DateTime
  field :rate_created, type: DateTime
  field :is_3D, type: Boolean
  field :promotion, type: String
  field :got_promotion, type: Boolean, default: false  # 优惠信息是否抓到。
  field :sku_properties_name, type: String

  field :news, type: Integer , default: 0 #是否从淘宝更新数据
  #  淘宝抓取过来的数据,本地老的数据进行更新后标记为"已更新",
  #  待其他操作(更新本地顾客)处理完毕后标记为已处理
  enum_attr :news, [["无更新",0],["已更新",1],["已处理",2]]

  embeds_many :taobao_orders
  embeds_many :promotion_details

  accepts_nested_attributes_for :taobao_orders

  attr_accessor :search_fields

  ## 分流相关 ##
  # def has_special_seller_memo?
  #   special_seller_memo.blank?
  # end

  # def special_seller_memo
  #   if self.fetch_account.key == 'dulux'
  #     if seller_memo.present?
  #       if seller_memo.strip == "@送货上门".strip
  #         "@送货上门"
  #       elsif seller_memo.strip == "@自提".strip
  #         "@自提"
  #       end
  #     end
  #   end
  # end

  def dispatchable?
    seller_id.blank? && status == 'WAIT_SELLER_SEND_GOODS'
  end

  def splitable?
    match_seller_with_conditions(self).size > 1
  end

  def matched_seller(area = nil)
    area ||= default_area
    if self.fetch_account.key == 'dulux'
      Dulux::SellerMatcher.match_trade_seller(self, area) unless splitable?
    else
      Dulux::SellerMatcher.match_trade_seller(self, area)
    end
  end

  def dispatch!(seller = nil)
    return false unless dispatchable?

    seller ||= matched_seller

    return false if seller.blank?

    # 更新订单状态为已分派
    update_attributes(seller_id: seller.id, seller_name: seller.name, dispatched_at: Time.now)

    # 如果满足自动化设置条件，分流后订单自动发货
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
      void_money = dispatch_conditions["void_money"].present? ? false : true || !has_refund_orders
      can_auto_dispatch = void_buyer_message && void_seller_memo && void_cs_memo && void_money
    end
    can_auto_dispatch && dispatchable?
  end

  def auto_dispatch!
    return unless auto_dispatchable?

    dispatch!

    operation_desc =  if seller_id
                        '自动分流'
                      else
                        '自动分流,未匹配到经销商'
                      end

    self.operation_logs.create(operated_at: Time.now, operation: operation_desc)
  end

  ## 发货相关 ##

  def deliverable?
    trades = TaobaoTrade.where(tid: tid).select do |trade|
      trade.orders.where(:refund_status.in => ['NO_REFUND', 'CLOSED']).size != 0
    end
    (trades.map(&:status) - ["WAIT_BUYER_CONFIRM_GOODS"]).size == 0 && !trades.map(&:delivered_at).include?(nil)
  end

  def deliver!
    return unless self.deliverable?
    TradeTaobaoDeliver.perform_async(self.id)
  end

  def auto_deliver!
    return unless self.deliverable?
    result = self.fetch_account.can_auto_deliver_right_now
    TradeTaobaoDeliver.perform_in((result == true ? 0 : result), self.id)
    trade.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
  end

  ## model属性方法 ##

  def orders
    self.taobao_orders
  end

  def orders=(new_orders)
    self.taobao_orders = new_orders
  end

  def out_iids
    self.orders.map {|o| o.outer_iid}
  end

  def receiver_address_array
    [self.receiver_state, self.receiver_city, self.receiver_district]
  end

  def calculate_fee
    goods_fee = self.orders.inject(0) { |sum, order| sum + order.total_fee.to_f}
    goods_fee.to_f + self.post_fee.to_f
  end

  def bill_infos_count
    self.orders.inject(0) { |sum, order| sum + order.bill_info.count }
  end

  def self.rescue_buyer_message(args)
    args.each do |tid|
      TradeTaobaoMemoFetcher.perform_async(tid)
    end
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
end