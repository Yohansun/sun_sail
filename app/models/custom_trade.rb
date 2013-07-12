# -*- encoding : utf-8 -*-

class CustomTrade < Trade
  include StockProductsLockable

  field :custom_type, type: String                     # 用于分类之后的本地化订单

  # 赠品订单特有field
  field :main_trade_id, type: String


  validates_presence_of :tid, :receiver_name, :receiver_mobile, :receiver_state, :receiver_city, :receiver_address, :created, :pay_time, message: "信息不完整"
  validates_uniqueness_of :tid, message: "操作频率过大，请重试"
  validates_length_of :receiver_name, maximum: 20, message: "内容过长"
  validates_length_of :receiver_address, maximum: 100, message: "内容过长"
  validates_length_of :cs_memo, maximum: 400, message: "内容过长"
  CH_EN_NUM_FORMAT = /^(\w|[\u4E00-\u9FA5])+$/
  validates :receiver_name, format: { with: CH_EN_NUM_FORMAT, message: "姓名格式不正确"}
  # validates :receiver_address, format: { with: CH_EN_NUM_FORMAT, message: "地址格式不正确"}
  MOBILE_FORMAT = %r{
                  ^(
                  1[38]\d{9}|  # 13 18 号段
                  15[^4]\d{8}|  # 15 号段
                  14[57]\d{8}  # 14 号段
                  )$
                  }x
  validates :receiver_mobile, format: { with: MOBILE_FORMAT, message: "手机号格式不正确"}
  validates_length_of :receiver_phone, maximum: 15, message: "内容过长", allow_blank: true
  validates :receiver_phone, format: { with: /^[0-9-]+$/, message: "座机号格式不正确"}, allow_blank: true
  validates :receiver_zip, format: { with: /^[0-9]{6}$/, message: "邮编格式不正确"}, allow_blank: true
  validate :created_larger_than_pay_time, :message => "下单时间不能晚于付款时间"

  embeds_many :taobao_orders

  def created_larger_than_pay_time
    if (pay_time.to_i - created.to_i) < 0
      errors.add(:created, "下单时间不能晚于付款时间")
    end
  end

  def orders
    self.taobao_orders
  end

  def deliver!
    main_trade = Trade.where(_id: main_trade_id).first
    # 如果是赠品订单，更新主订单赠品发货时间
    if main_trade
      gift_tid = tid.dup
      main_trade.trade_gifts.where(gift_tid: gift_tid).first.update_attributes(delivered_at: Time.now)
    end
    TradeTaobaoDeliver.perform_async(self.id)
  end

  def auto_deliver!
    main_trade = Trade.where(_id: main_trade_id).first
    # 如果是赠品订单，更新主订单赠品发货时间
    if main_trade
      gift_tid = tid.dup
      main_trade.trade_gifts.where(gift_tid: gift_tid).first.update_attributes(delivered_at: Time.now)
    end
    result = self.fetch_account.can_auto_deliver_right_now
    TradeTaobaoAutoDeliver.perform_in((result == true ? self.fetch_account.settings.auto_settings['deliver_silent_gap'].to_i.hours : result), self.id)
  end

  #### CustomTrade 目前默认不能自动分派 ####
  # def auto_dispatchable?
  #   dispatch_conditions = self.fetch_account.settings.auto_settings["dispatch_conditions"]
  #   if dispatch_conditions["void_buyer_message"] && dispatch_conditions["void_seller_memo"]
  #     can_auto_dispatch = !has_buyer_message && self.seller_memo.blank?
  #   elsif dispatch_conditions["void_buyer_message"] == 1 && dispatch_conditions["void_seller_memo"] == nil
  #     can_auto_dispatch = !has_buyer_message
  #   elsif dispatch_conditions["void_buyer_message"] == nil && dispatch_conditions["void_seller_memo"] == 1
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
  #                       '自动分派'
  #                     else
  #                       '自动分派,未匹配到经销商'
  #                     end

  #   self.operation_logs.create(operated_at: Time.now, operation: operation_desc)
  # end

  def matched_seller(area = nil)
    area ||= default_area
    SellerMatcher.match_trade_seller(self, area)
  end

  # def splitable?
  #   false
  # end

  # def calculate_fee
  #   goods_fee = self.orders.inject(0) { |sum, order| sum + order.total_fee.to_f}
  #   goods_fee.to_f + self.post_fee.to_f
  # end

  # def bill_infos_count
  #   self.orders.inject(0) { |sum, order| sum + order.bill_info.count }
  # end

  def self.make_new_trade(trade, current_account, current_user)
    trade[:receiver_state] = Area.find(trade[:receiver_state]).try(:name) rescue nil
    trade[:receiver_city]  = Area.find(trade[:receiver_city]).try(:name) rescue nil
    trade[:receiver_district] = Area.find(trade[:receiver_district]).try(:name) rescue nil
    custom_trade = new(trade)
    custom_trade.account_id = current_account.id
    custom_trade.tid = (Time.now.to_i.to_s + current_user.id.to_s + rand(10..99).to_s + "H" )
    custom_trade.custom_type = "handmade_trade"
    if trade[:has_invoice_info] == "true"
      custom_trade.invoice_type = "普通发票"
      custom_trade.invoice_name = "个人"
      custom_trade.invoice_date = Time.now
    end
    custom_trade
  end

  def change_params(trade)
    trade[:receiver_state] = Area.find(trade[:receiver_state]).try(:name) rescue nil
    trade[:receiver_city]  = Area.find(trade[:receiver_city]).try(:name) rescue nil
    trade[:receiver_district] = Area.find(trade[:receiver_district]).try(:name) rescue nil
    trade.each do |key, value|
      self[key] = value
    end
  end

  def change_orders(orders, status, action_name)
    taobao_orders.delete_all
    orders.each do |order|
      order_array = order.split(";")
      if action_name == 'create'
        new_order = taobao_orders.new()
      elsif action_name == 'update'
        new_order = taobao_orders.create()
      end
      new_order.oid = tid
      new_order.status = status
      new_order.refund_status = "NO_REFUND"
      new_order.seller_type = "B"
      new_order.num_iid = order_array[0]
      new_order.sku_id = (order_array[1] == "0" ? nil : order_array[1])
      new_order.num = order_array[2]
      new_order.payment = order_array[3]
      new_order.title = order_array[4]
      order_product = TaobaoProduct.find_by_num_iid(order_array[0])
      new_order.price = order_product.price
      new_order.cid =  order_product.cid
      new_order.pic_path = order_product.pic_url
    end
    self.payment = taobao_orders.inject(0){|sum, order| sum += order.payment }
    self.total_fee = taobao_orders.inject(0){|sum, order| sum += (order.price * order.num) }
  end

  def find_area_ids
    state_id = Area.where(parent_id: nil).find_by_name(receiver_state).id
    city_id = Area.where(parent_id: state_id).find_by_name(receiver_city).id
    district_id = Area.where(parent_id: city_id).find_by_name(receiver_district).id rescue nil
    area_ids = [state_id, city_id, district_id]
    area_ids
  end

  # 模拟淘宝订单
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