# -*- encoding : utf-8 -*-

class TaobaoTrade < Trade
  include StockProductsLockable
  #include Dulux::Splitter

  field :news, type: Integer , default: 0 #是否从淘宝更新数据
  #  淘宝抓取过来的数据,本地老的数据进行更新后标记为"已更新",
  #  待其他操作(更新本地顾客)处理完毕后标记为已处理
  enum_attr :news, [["无更新",0],["已更新",1],["已处理",2]]

  embeds_many :promotion_details
  embeds_many :taobao_orders

  validates_uniqueness_of :tid, message: "操作频率过大，请重试"

  accepts_nested_attributes_for :taobao_orders

  attr_accessor :search_fields

  ## 分派相关 ##
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

  # def splitable?
  #   match_seller_with_conditions(self).size > 1
  # end

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
    self.operation_logs.create(operated_at: Time.now, operation: "自动分派")
    self.save
  end

  ## 发货相关 ##

  def deliverable?
    trades = TaobaoTrade.where(tid: tid).select do |trade|
      trade.orders.where(:refund_status.in => ['NO_REFUND', 'CLOSED']).size != 0
    end
    (trades.map(&:status) - ["WAIT_BUYER_CONFIRM_GOODS"]).size == 0 && !trades.map(&:delivered_at).include?(nil)
  end

  # def deliver!
  #   return unless self.deliverable?
  #   TradeDeliver.perform_async(self.id)
  # end

  # def auto_deliver!
  #   result = self.fetch_account.can_auto_deliver_right_now
  #   TradeAutoDeliver.perform_in((result == true ? self.fetch_account.settings.auto_settings['deliver_silent_gap'].to_i.hours : result), self.id)
  #   self.is_auto_deliver = true
  #   self.operationπa_logs.create(operated_at: Time.now, operation: "自动发货")
  #   self.save
  # end

  ## model属性方法 ##

  # def calculate_fee
  #   goods_fee = self.orders.inject(0) { |sum, order| sum + order.total_fee.to_f}
  #   goods_fee.to_f + self.post_fee.to_f
  # end

  # def bill_infos_count
  #   self.orders.inject(0) { |sum, order| sum + order.bill_info.count }
  # end

  def self.rescue_buyer_message(args)
    args.each do |tid|
      TradeTaobaoMemoFetcher.perform_async(tid)
    end
  end

  # def orders_total_price
  #   self.orders.inject(0) { |sum, order| sum + order.price*order.num}
  # end

  # def vip_discount
  #   promotion_details.where(promotion_id: /^shopvip/i).sum(&:discount_fee)
  # end

  # def shop_bonus
  #   promotion_details.where(promotion_id: /^shopbonus/i).sum(&:discount_fee)
  # end

  # def shop_discount
  #   promotion_details.where(promotion_id: /^(?!shopvip|shopbonus)/i).sum(&:discount_fee)
  # end

  # def other_discount
  #   (total_fee + post_fee - payment - promotion_fee).to_f.round(2)
  # end

end