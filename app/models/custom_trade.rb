# -*- encoding : utf-8 -*-
#### CustomTrade 目前默认不能自动分派 ####

class CustomTrade < Trade
  include StockProductsLockable

  field :custom_type,   type: String      # 用于分类之后的本地化订单
  field :main_trade_id, type: String      # 赠品订单特有field,存贮主订单号

  validates_presence_of   :tid, :receiver_name, :receiver_state, :receiver_city, :receiver_address, :created, :pay_time, message: "信息不完整"
  validates_uniqueness_of :tid, message: "操作频率过大，请重试"
  validates_length_of     :receiver_name, maximum: 20, message: "内容过长"
  validates_length_of     :receiver_address, maximum: 100, message: "内容过长"
  validates_length_of     :cs_memo, maximum: 400, message: "内容过长"
  validates_format_of     :tid, with: /^[0-9A-Z]{15,19}$/, message: "只能是大写字母和数字，长度在15-19之间"
  validates               :receiver_mobile, format: { with: %r{^(1[38]\d{9}|15\d{9}|14\d{9})$}x, message: "手机号格式不正确"}, allow_blank: true
  validates_length_of     :receiver_phone, maximum: 20, message: "内容过长", allow_blank: true
  validates               :receiver_zip, format: { with: /^[0-9]{6}$/, message: "邮编格式不正确"}, allow_blank: true
  validate                :created_larger_than_pay_time, :message => "下单时间不能晚于付款时间"
  validate                :have_either_telephone_or_cell, :message => "手机号和座机号必须填写一个"

  embeds_many :taobao_orders

  before_update :check_finish_status

  def orders
    self.taobao_orders
  end

  def deliver!
    TradeDeliver.perform_async(self.id)
  end

  def auto_deliver!
    result = self.fetch_account.can_auto_deliver_right_now
    TradeAutoDeliver.perform_in(result, self.id)
    self.is_auto_deliver = true
    self.operation_logs.create(operated_at: Time.now, operation: "自动发货")
    self.save
  end

  def matched_seller(area = nil)
    area ||= default_area
    SellerMatcher.match_trade_seller(self.id, area)
  end

  def self.make_new_trade(trade, current_account, current_user)
    trade[:receiver_state]    = Area.find(trade[:receiver_state]).try(:name) rescue nil
    trade[:receiver_city]     = Area.find(trade[:receiver_city]).try(:name) rescue nil
    trade[:receiver_district] = Area.find(trade[:receiver_district]).try(:name) rescue nil
    custom_trade              = new(trade)
    custom_trade.account_id   = current_account.id
    custom_trade.custom_type  = trade[:custom_type] || "handmade_trade"
    if current_account.settings.open_auto_mark_invoice == 1
      if trade[:seller_memo]
        invoice_name = trade[:seller_memo].scan(/\$.*\$/).present? ? trade[:seller_memo].scan(/\$.*\$/).first : nil
      end
      if invoice_name.present?
        invoice_name.slice!(0)
        invoice_name.slice!(-1)
      else
        invoice_name = "个人"
      end
      custom_trade.invoice_name = invoice_name
      custom_trade.invoice_type = "需要开票"
      custom_trade.invoice_date = Time.now
    end
    custom_trade
  end

  def change_params(trade)
    trade[:receiver_state]    = Area.find(trade[:receiver_state]).try(:name) rescue nil
    trade[:receiver_city]     = Area.find(trade[:receiver_city]).try(:name) rescue nil
    trade[:receiver_district] = Area.find(trade[:receiver_district]).try(:name) rescue nil
    trade.each do |key, value|
      self[key] = value
    end
  end

  def change_orders(orders, status, calculate_payment, action_name)
    taobao_orders.delete_all
    orders.each do |order|
      order_array = order.split(";")
      if action_name == 'create'
        new_order = taobao_orders.new()
      elsif action_name == 'update'
        new_order = taobao_orders.create()
      end
      new_order.oid           = tid
      new_order.status        = status
      new_order.refund_status = "NO_REFUND"
      new_order.seller_type   = "B"
      new_order.outer_iid     = order_array[0]
      new_order.local_sku_id  = (order_array[1] == "0" ? nil : order_array[1])
      new_order.num           = order_array[2]
      new_order.payment       = order_array[3]
      new_order.title         = order_array[4]
      order_product           = Product.find_by_outer_id(order_array[0]) || TaobaoProduct.find_by_num_iid(order_array[0])
      new_order.price         = order_product.price
      new_order.cid           = order_product.cid
      new_order.pic_path      = order_product.pic_url
    end
    if calculate_payment.present?
      self.payment = calculate_payment
    else
      self.payment = taobao_orders.inject(0){|sum, order| sum += order.payment }
    end
    self.total_fee = taobao_orders.inject(0){|sum, order| sum += (order.price * order.num) }
  end

  def find_area_ids
    state_id    = Area.where(parent_id: nil).find_by_name(receiver_state).id
    city_id     = Area.where(parent_id: state_id).find_by_name(receiver_city).id
    district_id = Area.where(parent_id: city_id).find_by_name(receiver_district).id rescue nil
    area_ids    = [state_id, city_id, district_id]
    area_ids
  end

  def custom_type_name
    trade_types = fetch_account.settings.trade_types
    trade_types.symbolize_keys[custom_type.to_sym] || "其他订单"
  end

  private

  def created_larger_than_pay_time
    if (pay_time.to_i - created.to_i) < 0
      errors.add(:created, "下单时间不能晚于付款时间")
    end
  end

  def have_either_telephone_or_cell
    if (receiver_phone.blank? && receiver_mobile.blank?)
      errors.add(:receiver_phone, "手机号和座机号必须填写其中任一个")
      errors.add(:receiver_mobile, "手机号和座机号必须填写其中任一个")
    end
  end

  def check_finish_status
    status = 'TRADE_FINISHED' if confirm_receive_at.present?
  end
end