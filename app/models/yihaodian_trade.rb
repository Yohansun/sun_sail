# -*- encoding : utf-8 -*-

class YihaodianTrade < Trade

  #一号店特有字段
  field :order_id,                 type: Integer                 #订单ID
  field :receive_date,             type: DateTime                #确认收货时间
  field :pay_service_type,         type: Integer                 #订单支付方式
  field :order_promotion_discount, type: Float, default: 0.0     #参加促销活动立减金额
  field :update_time,              type: DateTime                #更新时间
  field :site_type,                type: Integer                 #获取销售平台
  field :order_coupon_discount,    type: Float, default: 0.0     #商家抵用券支付金额
  field :order_platform_discount,  type: Float, default: 0.0     #1mall平台抵用券支付金额
  field :end_user_id,              type: Integer                 #用户ID
  field :product_amount,           type: Float, default: 0.0     #产品总额

  #对应Trade字段
  field :tid,               as: :order_code, type: String
  field :status,            as: :order_status, type: String

  field :post_fee,          as: :order_delivery_fee, type: Float, default: 0.0
  field :payment,           as: :order_amount, type: Float, default: 0.0

  field :buyer_message,     as: :delivery_remark, type: String
  field :seller_memo,       as: :merchant_remark, type: String

  field :invoice_type,      as: :order_need_invoice, type: Integer
  field :invoice_name,      as: :invoice_title, type: String

  field :created,           as: :order_create_time, type: DateTime
  #注意一号店的付款时间目前一定在发货时间之前，但不能保证一直是这样
  field :pay_time,          as: :order_payment_confirm_date, type: DateTime
  field :consign_time,      as: :delivery_date, type: DateTime

  field :receiver_name,     as: :good_receiver_name, type: String
  field :receiver_address,  as: :good_receiver_address, type: String
  field :receiver_phone,    as: :good_receiver_phone, type: String
  field :receiver_mobile,   as: :good_receiver_moblie, type: String
  field :receiver_state,    as: :good_receiver_province, type: String
  field :receiver_city,     as: :good_receiver_city, type: String
  field :receiver_district, as: :good_receiver_county, type: String
  field :reciever_zip,      as: :good_receiver_post_code, type: String

  field :logistic_id,       as: :delivery_supplier_id, type: Integer
  field :logistic_waybill,  as: :merchant_express_nbr, type: String

  #退款字段
  field :refund_amount,     type: Float, default: 0.0
  field :refund_code,       type: String
  field :apply_date,        type: DateTime
  field :refund_status,     type: Integer

  embeds_many :yihaodian_orders

  enum_attr :status, [["已下单（货款未全收）", "ORDER_WAIT_PAY"],
                      ["已下单（货款已收）", "ORDER_PAYED"],
                      ["可以发货（已送仓库）", "ORDER_TRUNED_TO_DO"],
                      ["已出库（货在途）", "ORDER_CAN_OUT_OF_WH"],
                      ["已出库（货在途）", "ORDER_OUT_OF_WH"],
                      ["已发送物流", "ORDER_SENDED_TO_LOGITSIC"],
                      ["货物用户已收到", "ORDER_RECEIVED"],
                      ["订单完成", "ORDER_FINISH"],
                      ["用户要求退货", "ORDER_CUSTOM_CALLTO_RETURN"],
                      ["用户要求换货", "ORDER_CUSTOM_CALLTO_CHANGE"],
                      ["退货完成", "ORDER_RETURNED"],
                      ["换货完成", "ORDER_CHANGE_FINISHED"],
                      ["订单取消", "ORDER_CANCEL"]],:not_valid => true

  enum_attr :invoice_type, [["不需要", 0],
                            ["旧版普通", 1],
                            ["新版普通", 2],
                            ["增值税发票", 3]],:not_valid => true

  enum_attr :pay_service_type, [["账户支付", 0],
                                ["网上支付", 1],
                                ["货到付款", 2],
                                ["邮局汇款", 3],
                                ["银行转账", 4],
                                ["pos机", 5],
                                ["万里通", 6],
                                ["分期付款", 7],
                                ["合同账期", 8],
                                ["货到转账", 9],
                                ["货到付支票", 10]],:not_valid => true

  enum_attr :refund_status, [["待审核", 0],
                             ["客服仲裁", 3],
                             ["已拒绝", 4],
                             ["退货中-待顾客寄回", 11],
                             ["退货中-待确认退款", 12],
                             ["换货中", 13],
                             ["退款完成", 27],
                             ["换货完成", 33],
                             ["已撤销", 34],
                             ["已关闭", 40]], not_valid: true

  def total_fee
    product_amount + post_fee
  end

  def discount_fee
    order_promotion_discount + order_coupon_discount + order_platform_discount
  end

  def orders
    self.yihaodian_orders
  end

  def orders=(new_orders)
    self.yihaodian_orders = new_orders
  end

  ## 分派相关 ##
  def matched_seller(area = nil)
    area ||= default_area
    SellerMatcher.match_trade_seller(self.id, area)
  end

  #没有考虑物流分组和物流拆分
  def generate_deliver_bill
    deliver_bills.delete_all
    bill = deliver_bills.create(deliver_bill_number: "#{tid}01", seller_id: seller_id, seller_name: seller_name, account_id: account_id)
    orders.each do |order|
      yihaodian_sku = order.yihaodian_sku || order.local_skus.first
      sku_id = yihaodian_sku.try(:id)
      sku_name = yihaodian_sku.try(:product_cname)
      bill.bill_products.create(title: order.title, outer_id: order.outer_id, num_iid: order.num_iid, sku_id: sku_id, sku_name: sku_name, colors: order.color_num, number: order.num, memo: order.cs_memo)
    end
  end

  def deliverable?
    self.orders.where(:refund_status.in => ['NO_REFUND', 'CLOSED']).size != 0 &&
    self.is_paid_and_delivered &&
    self.delivered_at.present?
  end

  def deliver!
    return unless self.deliverable?
    TradeYihaodianDeliver.perform_async(self.id)
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

  # http://openapi.1mall.com/app/inshop/yhd.logistics.order.shipments.update.html
  # 订单发货(更新订单物流信息)
  def shipment
    raise "只有待发货状态ORDER_TRUNED_TO_DO的订单才可以进行发货操作" if status_order_truned_to_do?
    api = 'yhd.logistics.order.shipments.update'
    @response ||= YihaodianQuery.post({method: api,orderCode: tid, deliverySupplierId: service_logistic_id, expressNbr: logistic_waybill },trade_source.try(:yihaodian_query_conditions))
    @response["response"]["updateCount"].to_i == 1 || @response["response"]["errInfoList"]['errDetailInfo']
  end

  def account
    @account ||= Account.find account_id
  end

end