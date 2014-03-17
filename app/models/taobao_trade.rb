# -*- encoding : utf-8 -*-

class TaobaoTrade < Trade
  include StockProductsLockable
  #include Dulux::Splitter
  include Mongoid::History::Trackable

  #交易完成订单对应支付宝帐单的最后一次修改时间
  field :alipay_last_modified_time, type: DateTime
  field :alipay_payment, type: Float

  embeds_many :promotion_details
  embeds_many :taobao_orders

  enum_attr :status, [["没有创建支付宝交易"                ,"TRADE_NO_CREATE_PAY"],
                      ["等待买家付款"                     ,"WAIT_BUYER_PAY"],
                      ["等待卖家发货,即:买家已付款"         ,"WAIT_SELLER_SEND_GOODS"],
                      ["等待买家确认收货,即:卖家已发货"      ,"WAIT_BUYER_CONFIRM_GOODS"],
                      ["买家已签收,货到付款专用"            ,"TRADE_BUYER_SIGNED"],
                      ["交易成功"                         ,"TRADE_FINISHED"],
                      ["付款以后用户退款成功，交易自动关闭"   ,"TRADE_CLOSED"],
                      ["付款以前，卖家或买家主动关闭交易"     ,"TRADE_CLOSED_BY_TAOBAO"]],:not_valid => true

  validates_uniqueness_of :tid, message: "操作频率过大，请重试"

  accepts_nested_attributes_for :taobao_orders

  attr_accessor :search_fields

  ## 用于跟踪订单被抓取到系统的字段的变化情况
  ## 查询方法：trade.history_tracks
  ## 注意目前只设置了淘宝订单的相关字段！
  track_history :on => [:total_fee, :created, :tid, :status, :post_fee, :receiver_name, :pay_time, :end_time, :receiver_state, :receiver_city, :receiver_district, :receiver_address, :receiver_zip, :receiver_mobile, :receiver_phone, :buyer_nick, :tile, :type, :point_fee, :is_lgtype, :is_brand_sale, :is_force_wlb, :modified, :alipay_id, :alipay_no, :alipay_url, :shipping_type, :buyer_obtain_point_fee, :cod_fee, :cod_status, :commission_fee, :seller_nick, :consign_time, :received_payment, :payment, :timeout_action_time, :has_buyer_message, :real_point_fee],
                :version_field  =>  :version,  # adds "field :version, :type => Integer" to track current version, default is :version
                :track_create   =>  true,      # track document creation, default is false
                :track_update   =>  true,      # track document updates, default is true
                :track_destroy  =>  false      # track document destruction, default is false

  def matched_seller(area = nil)
    area ||= default_area
    SellerMatcher.match_trade_seller(self.id, area)
  end

  def deliverable?
    trades = TaobaoTrade.where(tid: tid).select do |trade|
      trade.orders.where(:refund_status.in => ['NO_REFUND', 'CLOSED']).size != 0
    end
    (trades.map(&:status) - ["WAIT_BUYER_CONFIRM_GOODS"]).size == 0 && !trades.map(&:delivered_at).include?(nil)
  end

  def self.rescue_buyer_message(args)
    args.each do |tid|
      TradeTaobaoMemoFetcher.perform_async(tid)
    end
  end

  ##DEPRECATED

  ## model属性方法 ##

  # def calculate_fee
  #   goods_fee = self.orders.inject(0) { |sum, order| sum + order.total_fee.to_f}
  #   goods_fee.to_f + self.post_fee.to_f
  # end

  # def bill_infos_count
  #   self.orders.inject(0) { |sum, order| sum + order.bill_info.count }
  # end

  def set_alipay_data
    if status == "TRADE_FINISHED"
      start_time = consign_time || delivered_at || end_time
      # 开始和结束时间跨度不能超过7天
      response = TaobaoQuery.get({method: 'alipay.user.trade.search',
                                  start_time: (start_time - 1.day).strftime("%Y-%m-%d %H:%M:%S"),
                                  end_time: (start_time + 6.days).strftime("%Y-%m-%d %H:%M:%S"),
                                  alipay_order_no: alipay_no,
                                  order_type: 'TRADE',
                                  order_status: 'TRADE_FINISHED',
                                  order_from: "TAOBAO",
                                  page_no: 1,
                                  page_size: 10},
                                  trade_source_id
                                )
      modified_time = response['alipay_user_trade_search_response']['trade_records']['trade_record'][0]['modified_time'].to_time(:local) rescue nil
      total_amount = response['alipay_user_trade_search_response']['trade_records']['trade_record'][0]['total_amount'] rescue nil
      self.alipay_last_modified_time = modified_time if modified_time
      self.alipay_payment = total_amount.to_f if total_amount
    end
  end
end