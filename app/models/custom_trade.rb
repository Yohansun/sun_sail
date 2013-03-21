# -*- encoding : utf-8 -*-

class CustomTrade < Trade
  include TaobaoProductsLockable

  field :tid, type: String
  field :num, type: Integer
  field :num_iid, type: String
  field :status, type: String
  field :title, type: String
  field :type, type: String

  field :seller_memo, type: String
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
  field :custom_type, type: String                     # 用于分类之后的本地化订单
  #Special field for gift_trade ONLY
  field :main_trade_id, type: String

  embeds_many :taobao_orders

  def orders
    self.taobao_orders
  end

  def deliver!
    gift_tid = tid.dup
    tid.slice!(/G[0-9]$/)
    # NEED ADAPTION?
    Trade.where(tid: tid).first.trade_gifts.where(gift_tid: gift_tid).first.update_attributes(delivered_at: Time.now)
    TradeTaobaoDeliver.perform_async(self.id)
  end

  # def auto_dispatchable?
  #   dispatch_options = self.fetch_account.settings.auto_settings["dispatch_options"]
  #   if dispatch_options["void_buyer_message"] && dispatch_options["void_seller_memo"]
  #     can_auto_dispatch = !has_buyer_message && self.seller_memo.blank?
  #   elsif dispatch_options["void_buyer_message"] == 1 && dispatch_options["void_seller_memo"] == nil
  #     can_auto_dispatch = !has_buyer_message
  #   elsif dispatch_options["void_buyer_message"] == nil && dispatch_options["void_seller_memo"] == 1
  #     can_auto_dispatch = self.seller_memo.blank?
  #   else
  #     can_auto_dispatch = true
  #   end

  #   can_auto_dispatch && has_special_seller_memo? && dispatchable?
  # end

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

  # def auto_dispatch!
  #   return unless auto_dispatchable?

  #   dispatch!

  #   operation_desc =  if seller_id
  #                       '自动分流'
  #                     else
  #                       '自动分流,未匹配到经销商'
  #                     end

  #   self.operation_logs.create(operated_at: Time.now, operation: operation_desc)
  # end

  def dispatch!(seller = nil)
    return false unless dispatchable?

    seller ||= matched_seller

    return false if seller.blank?

    # 锁定库存
    nofity_stock '锁定', seller.id

    # 更新订单状态为已分流
    update_attributes(seller_id: seller.id, seller_name: seller.name, dispatched_at: Time.now)

    # 如果满足自动化设置条件，分流后订单自动发货
    auto_settings = self.fetch_account.settings.auto_settings
    if auto_settings['auto_deliver'] && self.fetch_account.can_auto_deliver_right_now?
      if auto_settings["deliver_condition"] == "dispatched_trade" && deliverable?
        deliver!
        self.operation_logs.create(operated_at: Time.now, operation: "订单自动发货")
      end
    end

    # 生成默认发货单
    generate_deliver_bill
  end

  def matched_seller(area = nil)
    area ||= default_area
    if self.fetch_account.key == 'dulux'
      Dulux::SellerMatcher.match_trade_seller(self, area) unless splitable?
    else
      Dulux::SellerMatcher.match_trade_seller(self, area)
    end
  end

  def splitable?
    false
  end

  def dispatchable?
    seller_id.blank? && status == 'WAIT_SELLER_SEND_GOODS'
  end

  def out_iids
    self.orders.map {|o| o.outer_iid}
  end

  def receiver_address_array
    [self.receiver_state, self.receiver_city, self.receiver_district]
  end

  def calculate_fee
    0
  end

  def bill_infos_count
    self.orders.inject(0) { |sum, order| sum + order.bill_info.count }
  end

  def self.rescue_buyer_message(args)
    args.each do |tid|
      TradeTaobaoMemoFetcher.perform_async(tid, false)
    end
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