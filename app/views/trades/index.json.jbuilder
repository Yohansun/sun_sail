json.list(@trades) do |json, trade|

  ## 订单参数

  json.trades_count               @trades_count
  json.id                         trade._id
  json.tid                        trade.tid
  json.trade_type                 trade._type
  json.shop_name                  trade.shop_name
  json.tc_order_id                trade.tc_order_id if trade._type == "TaobaoPurchaseOrder"
  json.distributor_usercode       trade.distributor_usercode if trade._type == "TaobaoPurchaseOrder"
  json.splitted_tid               trade.splitted_tid
  json.status                     trade.status
  json.status_text                trade.status_text
  json.receiver_name              trade.receiver_name
  json.receiver_mobile_phone      trade.receiver_mobile_phone
  json.receiver_address           trade.receiver_address
  json.receiver_district          trade.receiver_district
  json.receiver_city              trade.receiver_city
  json.receiver_state             trade.receiver_state
  json.buyer_message              trade.buyer_message
  json.interface_name             trade.interface_name
  json.interface_mobile           trade.interface_mobile
  json.deliver_bill_count         trade.deliver_bills.count
  json.buyer_nick                 trade.buyer_nick
  json.seller_memo                trade.seller_memo
  json.has_split_deliver_bill     trade.has_split_deliver_bill
  json.trade_source               trade.trade_source
  json.created                    trade.created.strftime("%m-%d %H:%M") if trade.created
  json.created_timestamp          trade.created.to_i if trade.created
  json.pay_time                   trade.pay_time.strftime("%m-%d %H:%M") if trade.pay_time
  json.cs_memo                    trade.cs_memo
  json.gift_memo                  trade.gift_memo
  json.deliver_bill_printed_at    trade.deliver_bill_printed_at.try(:strftime, "%m-%d %H:%M")
  json.logistic_printed_at        trade.logistic_printed_at.try(:strftime, "%m-%d %H:%M")
  json.has_color_info             trade.has_color_info
  json.has_cs_memo                trade.has_cs_memo
  json.has_unusual_state          trade.has_unusual_state
  json.has_property_memos         trade.has_property_memos
  json.last_unusual_state         trade.last_unusual_state
  json.has_onsite_service         trade.has_onsite_service
  json.has_refund_orders          trade.has_refund_orders
  json.unusual_color_class        trade.unusual_color_class if trade.unusual_color_class
  json.can_change_logistic        can_change_logistic(trade)
  json.invoice_type               trade._type == "YihaodianTrade" ? trade.invoice_type_name : trade.invoice_type
  json.invoice_name               trade.invoice_name
  json.invoice_content            trade.invoice_content
  json.invoice_date               trade.invoice_date.strftime("%Y-%m-%d") if trade.invoice_date
  json.invoice_value              trade.total_fee
  json.point_fee                  trade.point_fee
  json.total_fee                  trade.total_fee
  json.operator                   trade.operator_name
  json.logistic_id                trade.logistic_id
  json.logistic_name              trade.logistic_name
  json.logistic_waybill           trade.logistic_waybill
  json.seller_confirm_deliver_at  trade.seller_confirm_deliver_at.strftime("%m-%d %H:%M") if trade.seller_confirm_deliver_at
  json.seller_confirm_invoice_at  trade.seller_confirm_invoice_at.strftime("%m-%d %H:%M") if trade.seller_confirm_invoice_at
  json.confirm_color_at           trade.confirm_color_at.strftime("%m-%d %H:%M") if trade.confirm_color_at
  json.confirm_check_goods_at     trade.confirm_check_goods_at.strftime("%m-%d %H:%M") if trade.confirm_check_goods_at
  json.confirm_receive_at         trade.confirm_receive_at.strftime("%m-%d %H:%M") if trade.confirm_receive_at
  json.request_return_at          trade.request_return_at.strftime("%m-%d %H:%M") if trade.request_return_at
  json.confirm_return_at          trade.confirm_return_at.strftime("%m-%d %H:%M") if trade.confirm_return_at
  json.confirm_refund_at          trade.confirm_refund_at.strftime("%m-%d %H:%M") if trade.confirm_refund_at
  json.consign_time               (trade.consign_time || trade.delivered_at).try(:strftime, "%m-%d %H:%M")
  json.dispatched_at              trade.dispatched_at.strftime("%m-%d %H:%M") if trade.dispatched_at
  json.seller_id                  trade.seller_id
  json.seller_name                trade.seller_name
  json.main_trade_id              trade.main_trade_id if trade.main_trade_id
  json.add_ref                    trade.add_ref
  json.return_ref                 trade.return_ref
  json.refund_ref                 trade.refund_ref
  json.merged_trade_ids           trade.merged_trade_ids
  json.merged_by_trade_id         trade.merged_by_trade_id
  json.mergeable_id               trade.mergeable_id
  json.is_locked                  trade.is_locked
  json.is_paid_not_delivered      trade.is_paid_not_delivered
  json.is_paid_and_delivered      trade.is_paid_and_delivered
  json.is_succeeded               trade.is_succeeded
  json.is_closed                  trade.is_closed
  json.auto_dispatch_left_seconds trade.auto_dispatch_left_seconds(current_account)

  ## 订单子文档

  json.orders OrderDecorator.decorate(trade.orders) do |json, order|
    json.id order._id
    json.title order.title
    json.num order.num
    json.order_gift_tid order.order_gift_tid
    json.cs_memo order.cs_memo
    json.color_num order.color_num
    json.color_hexcode order.color_hexcode
    json.color_name order.color_name
  end

  json.gift_orders gift_orders(trade) do |json, gift_order|
    json.order_id     gift_order._id
    json.gift_tid     gift_order.trade.tid
    json.is_split     gift_order.trade.main_trade_id.present?
    json.gift_title   gift_order.title
    json.num          gift_order.num
    json.delivered_at gift_order.trade.delivered_at
  end

  ## 出库单状态

  stock_out_bill = trade.stock_out_bill if trade.stock_out_bill
  json.stock_out_bill_present stock_out_bill.present?
  json.stock_status           stock_out_bill.status if stock_out_bill
  json.can_do_close           !!stock_out_bill && stock_out_bill.can_do_close?
end

json.counter_cache(counter_caches(current_account.id))