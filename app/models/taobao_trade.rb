# -*- encoding : utf-8 -*-

class TaobaoTrade < Trade
  include TaobaoProductsLockable
  include Dulux::Splitter

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
  field :discount_fee, type: Float
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
  field :is_3D, type: Boolean
  field :promotion, type: String

  embeds_many :taobao_orders

  accepts_nested_attributes_for :taobao_orders

  def orders
    self.taobao_orders
  end

  def orders=(new_orders)
    self.taobao_orders = new_orders
  end

  def deliverable?
    status_array = TaobaoTrade.where(tid: tid).map(&:status)
    undeliverable_status = status_array - ['WAIT_SELLER_SEND_GOODS']
    undeliverable_status.size == 0
  end

  def deliver!
    return unless self.deliverable?
    TradeTaobaoDeliver.perform_async(self.id)
  end

  def auto_dispatchable? 
    !has_buyer_message && has_special_seller_memo?
  end

  def has_special_seller_memo?
    if TradeSetting.company == 'dulux'
      seller_memo.present? && (seller_memo.strip == "@送货上门".strip || seller_memo.strip == "@自提".strip)
    else
      seller_memo.blank?
    end  
  end  

  def special_seller_memo
    if TradeSetting.company == 'dulux'
      if seller_memo.present?
        if seller_memo.strip == "@送货上门".strip
          "@送货上门"
        elsif seller_memo.strip == "@自提".strip
          "@自提"
        end
      end    
    end  
  end  

  def auto_dispatch!
    return unless auto_dispatchable?
    dispatch!
  end

  def dispatch!(seller = nil)
    # if TradeSetting.company == 'dulux'
    #   split_orders(self)
    # else

    if TradeSetting.company == 'dulux' && self.has_special_seller_memo? && self.special_seller_memo.present?
      cs_memo = "#{self.cs_memo} #{self.special_seller_memo}"
      self.update_attributes!(cs_memo: cs_memo) 
    end

    return false unless dispatchable?
    unless seller
      seller = matched_seller
      self.operation_logs.create!(operated_at: Time.now, operation: '分流未匹配到经销商')  
    end

    return false unless seller

    if seller.has_stock
      return false unless can_lock_products?(self, seller.id)
    end

    orders.each do |order|
      product = Product.find_by_iid order.outer_iid
      stock_product = StockProduct.where(product_id: product.id, seller_id: seller.id).first
      break unless product
      stock_product.update_quantity!(order.num, '锁定', seller.id, tid)
    end

    if seller
      update_attributes(seller_id: seller.id, seller_name: seller.name, dispatched_at: Time.now)
      self.operation_logs.create!(operated_at: Time.now, operation: '延时自动分流')
    end

  end

  def reset_seller
    return unless seller_id

    orders.each do |order|
      product = Product.find_by_iid order.outer_iid
      stock_product = StockProduct.where(product_id: product.id, seller_id: seller_id).first
      break unless product
      stock_product.update_quantity!(order.num, '解锁', seller_id, tid)
    end

    update_attributes(seller_id: nil, seller_name: nil, dispatched_at: nil)
  end

  def matched_seller(area = nil)
    area ||= default_area
    if TradeSetting.company == 'dulux'
      Dulux::SellerMatcher.match_trade_seller(self, area) unless splitable?
    else
      super
    end
  end

  def splitable?
    match_seller_with_conditions(self).size > 1
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
    goods_fee = self.orders.inject(0) { |sum, order| sum + order.total_fee.to_f}
    goods_fee.to_f + self.post_fee.to_f
  end
end
