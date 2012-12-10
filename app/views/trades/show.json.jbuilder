json.id @trade._id
json.tid @trade.tid
json.trade_type @trade._type
json.current_user_is_seller current_user.has_role?(:seller)
json.splitted_tid @trade.splitted_tid
json.seller_id @trade.seller_id
json.default_seller_id TradeSetting.default_seller_id
json.shopname TradeSetting.shopname
json.seller_name @trade.seller.name if @trade.seller
json.status @trade.status
json.status_text @trade.status_text
json.receiver_name @trade.receiver_name
json.receiver_mobile_phone @trade.receiver_mobile_phone
json.receiver_address @trade.receiver_address
json.receiver_district @trade.receiver_district
json.receiver_city @trade.receiver_city
json.receiver_state @trade.receiver_state
json.receiver_zip @trade.receiver_zip
json.trade_source @trade.trade_source
json.trade_source_name @trade.trade_source_name
json.buyer_message @trade.buyer_message
json.seller_memo @trade.seller_memo
json.post_fee @trade.post_fee
json.payment @trade.payment

unless TradeSetting.company == 'dulux' && (current_user.has_role?(:seller) || current_user.has_role?(:logistic))
  json.seller_discount @trade.seller_discount
  json.sum_fee @trade.sum_fee
  json.point_fee @trade.point_fee
  json.total_fee @trade.total_fee
end

json.created @trade.created.strftime("%m-%d %H:%M")
json.pay_time @trade.pay_time.strftime("%m-%d %H:%M") if @trade.pay_time
json.cs_memo @trade.cs_memo
json.gift_memo @trade.gift_memo
json.has_color_info @trade.has_color_info
json.has_cs_memo @trade.has_cs_memo
json.has_unusual_state @trade.has_unusual_state
json.has_refund_order @trade.has_refund_order
json.logistic_code @trade.logistic_code
json.logistic_id @trade.logistic_id
json.logistic_name @trade.logistic_name
json.logistic_company @trade.logistic_company
json.logistic_waybill @trade.logistic_waybill
json.matched_logistics @trade.matched_logistics
json.logistic_memo @trade.logistic_memo

json.invoice_type @trade.invoice_type
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
  unless TradeSetting.company == 'dulux' && current_user.has_role?(:seller)
    if current_user.has_role?(:seller) && @trade._type == "TaobaoPurchaseOrder"
      json.price order.price
      json.total_fee order.seller_total_fee
    else
      json.price order.auction_price
      json.total_fee order.total_fee
    end
    json.auction_price order.auction_price
    json.total_fee order.total_fee
    json.buyer_payment order.buyer_payment
    json.distributor_payment order.distributor_payment
  end
  json.item_id order.item_id
  json.sku_properties order.sku_properties
  json.item_outer_id order.item_outer_id
  json.cs_memo order.cs_memo
  json.color_num order.color_num
  json.color_hexcode order.color_hexcode
  json.color_name order.color_name
  json.barcode order.barcode

  if @trade._type == 'TaobaoTrade'
    json.refund_status order.refund_status
  end

  json.contents @trade._type == 'TaobaoTrade' ? get_package(order.outer_iid, @trade.created_at) : []
  json.bill_info order.bill_info
  json.packaged order.product.try(:package_info).present?
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
  json.id log.id
  json.operator log.operator
  json.operator_id log.operator_id
  json.operated_at log.operated_at.strftime("%m-%d %H:%M:%S") if log.operated_at
  json.operation log.operation
end

if params[:splited]
  json.splited @splited_orders
end
