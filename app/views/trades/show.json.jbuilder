json.id @trade._id
json.tid @trade.tid
json.trade_type @trade._type
json.current_user_is_seller current_user.seller.present?
json.splitted_tid @trade.splitted_tid
json.seller_id @trade.seller_id
json.default_seller_id current_account.settings.default_seller_id
json.default_jingdong_seller_id current_account.settings.default_jingdong_seller_id
json.default_yihaodian_seller_id current_account.settings.default_yihaodian_seller_id
json.shopname @trade.seller_nick
json.seller_name @trade.seller.name if @trade.seller
json.status @trade.status
json.status_text @trade.status_text
json.receiver_name @trade.receiver_name
json.receiver_mobile_phone @trade.receiver_mobile_phone
json.receiver_phone @trade.receiver_phone
json.receiver_address @trade.receiver_address
json.receiver_district @trade.receiver_district
json.receiver_city @trade.receiver_city
json.receiver_state @trade.receiver_state
json.receiver_zip @trade.receiver_zip
json.trade_source @trade.trade_source
json.trade_source_name @trade.trade_source_name
json.buyer_message @trade.buyer_message
json.buyer_nick @trade.buyer_nick
json.seller_memo @trade.seller_memo
json.post_fee @trade.post_fee
json.modify_payment @trade.modify_payment
json.modify_payment_no @trade.modify_payment_no
json.modify_payment_at @trade.modify_payment_at.strftime("%Y-%m-%d") if @trade.modify_payment_at
json.modify_payment_memo @trade.modify_payment_memo
json.seller_discount @trade.seller_discount
json.sum_fee @trade.sum_fee
json.point_fee @trade.point_fee
json.total_fee @trade.total_fee

json.created @trade.created.strftime("%m-%d %H:%M") if @trade.created
json.pay_time @trade.pay_time.strftime("%m-%d %H:%M") if @trade.pay_time
json.cs_memo @trade.cs_memo
json.trade_with_orders_cs_memo @trade.trade_with_orders_cs_memo
json.gift_memo @trade.gift_memo
json.has_color_info @trade.has_color_info
json.has_cs_memo @trade.has_cs_memo
json.has_unusual_state @trade.has_unusual_state
json.unusual_color_class @trade.unusual_color_class if @trade.unusual_color_class
json.logistic_code @trade.logistic_code
json.logistic_id @trade.logistic_id
json.logistic_name @trade.logistic_name
json.logistic_company @trade.logistic_company
json.logistic_waybill @trade.logistic_waybill
json.matched_logistics @trade.matched_logistics
json.logistic_memo @trade.logistic_memo

json.invoice_type @trade._type == "YihaodianTrade" ? @trade.invoice_type_name : @trade.invoice_type
json.invoice_name @trade.invoice_name
json.invoice_content @trade.invoice_content
json.invoice_date @trade.invoice_date.strftime("%Y-%m-%d") if @trade.invoice_date
json.invoice_number @trade.invoice_number
json.seller_confirm_deliver_at @trade.seller_confirm_deliver_at.strftime("%m-%d %H:%M") if @trade.seller_confirm_deliver_at
json.seller_confirm_invoice_at @trade.seller_confirm_invoice_at.strftime("%m-%d %H:%M") if @trade.seller_confirm_invoice_at
json.confirm_color_at @trade.confirm_color_at.strftime("%m-%d %H:%M") if @trade.confirm_color_at
json.confirm_check_goods_at @trade.confirm_check_goods_at.strftime("%m-%d %H:%M") if @trade.confirm_check_goods_at
json.confirm_receive_at @trade.confirm_receive_at.strftime("%m-%d %H:%M") if @trade.confirm_receive_at
json.deliver_bill_printed_at @trade.deliver_bill_printed_at if @trade.deliver_bill_printed_at
json.deliver_bill_count @trade.deliver_bills.count
json.request_return_at @trade.request_return_at.strftime("%m-%d %H:%M") if @trade.request_return_at
json.confirm_return_at @trade.confirm_return_at.strftime("%m-%d %H:%M") if @trade.confirm_return_at
json.confirm_refund_at @trade.confirm_refund_at.strftime("%m-%d %H:%M") if @trade.confirm_refund_at

if @trade.consign_time
  json.consign_time @trade.consign_time.strftime("%m-%d %H:%M")
else
  if @trade.delivered_at
    json.consign_time @trade.delivered_at.strftime("%m-%d %H:%M")
  end
end

json.dispatched_at @trade.dispatched_at.strftime("%m-%d %H:%M") if @trade.dispatched_at

json.orders OrderDecorator.decorate(@trade.orders) do |json, order|
  json.id order._id
  json.title order.title
  json.num order.num
  json.price order.price

  json.item_id order.item_id
  json.sku_properties order.sku_properties
  json.item_outer_id order.item_outer_id
  json.cs_memo order.cs_memo
  json.color_num order.color_num
  json.color_hexcode order.color_hexcode
  json.color_name order.color_name
  json.barcode order.barcode
  json.refund_status_text order.refund_status_text
  json.order_gift_tid order.order_gift_tid
  json.sku_bindings order.sku_bindings
  json.local_sku_id order.local_sku_id

  if @trade._type == 'TaobaoTrade'
    json.refund_status order.refund_status
  end

  json.contents get_package(order)
  json.bill_info order.bill_info
  json.packaged false
  json.package_info order.package_info
end

json.add_ref @trade.add_ref
json.return_ref @trade.return_ref
json.refund_ref @trade.refund_ref

if @trade._type == "TaobaoPurchaseOrder"
  json.distributor_username @trade.distributor_username
  json.distributor_payment @trade.distributor_payment
end

json.unusual_states @trade.unusual_states do |json, state|
  json.id state._id
  json.reason state.reason
  json.note state.note
  json.created_at state.created_at.strftime("%m-%d %H:%M:%S") if state.created_at
  json.plan_repair_at state.plan_repair_at.strftime("%m-%d") if state.plan_repair_at
  json.reporter state.reporter
  json.repair_man state.repair_man
  json.repaired_at state.repaired_at.strftime("%m-%d %H:%M:%S") if state.repaired_at
end

json.operation_logs @trade.operation_logs do |json, log|
  json.id log._id
  json.operator log.operator
  json.operator_id log.operator_id
  json.operated_at log.operated_at.strftime("%m-%d %H:%M:%S") if log.operated_at
  json.operation log.operation
end

json.trade_gifts @trade.trade_gifts do |json, gift|
  json.id gift._id
  json.product_id gift.product_id
  json.gift_tid gift.gift_tid
  json.trade_id gift.trade_id
  json.gift_title gift.gift_title
  json.num_iid gift.num_iid
  json.sku_id gift.sku_id
  json.num gift.num
  json.delivered_at gift.delivered_at
end

#for gift_trade only!
json.main_trade_id @trade.main_trade_id if @trade.main_trade_id

if params[:splited]
  json.splited @splited_orders
end

json.splited_bills @trade.model.logistic_split
json.merged_trade_ids @trade.merged_trade_ids
json.merged_by_trade_id @trade.merged_by_trade_id
json.mergeable_id @trade.mergeable_id

json.is_paid_not_delivered @trade.is_paid_not_delivered
json.is_paid_and_delivered @trade.is_paid_and_delivered
json.is_succeeded @trade.is_succeeded
json.is_closed @trade.is_closed

json.is_locked @trade.is_locked
json.auto_dispatch_left_seconds @trade.auto_dispatch_left_seconds(current_account)

#出库单状态
stock_out_bill = @trade.stock_out_bill if @trade.stock_out_bill
json.stock_out_bill_present stock_out_bill.present?
json.stock_status stock_out_bill.status if stock_out_bill
json.can_do_close !!stock_out_bill && stock_out_bill.can_do_close?
