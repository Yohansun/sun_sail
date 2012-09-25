# -*- encoding : utf-8 -*-

class TaobaoTrade < Trade
  include TaobaoProductsLockable

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
  field :seller_alipay_no, type: String
  field :seller_mobile, type: String
  field :seller_phone, type: String
  field :seller_name, type: String
  field :seller_email, type: String
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
    return false if self.status != "WAIT_SELLER_SEND_GOODS"
    sibling = (TaobaoTrade.where(tid: self.tid).to_a - [self]).first
    sibling.blank? || (sibling.present? && sibling.delivered_at.present?)
  end

  def deliver!
    return unless self.deliverable?
    TradeTaobaoDeliver.perform_async(self.id)
  end

  def auto_dispatchable?
    !has_buyer_message && seller_memo.blank?
  end

  def auto_dispatch!
    return unless auto_dispatchable?
    dispatch!
  end

  def dispatch!(seller = nil)
    return false unless self.dispatchable?

    unless seller
      seller = matched_seller_with_default

      return false unless seller

      if seller.has_stock
        return false unless can_lock_products?(seller.id)
      end
    end

    update_attributes(seller_id: seller.id, dispatched_at: Time.now) if seller
  end

  def matched_seller_with_default(area = nil)
    matched_seller(area) || Seller.find(1720)
  end

  def matched_seller(area = default_area)
    if TradeSetting.company == 'dulux'
      Dulux::SellerMatcher.match_trade_seller(self, area)
    else
      super
    end
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
end