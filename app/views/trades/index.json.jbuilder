json.array!(@trades) do |json, trade|
  json.trades_count @trades_count
  json.id trade._id
  json.tid trade.tid
  json.tc_order_id trade.tc_order_id if trade._type == "TaobaoPurchaseOrder"
  json.distributor_usercode trade.distributor_usercode if trade._type == "TaobaoPurchaseOrder"
  json.splitted_tid trade.splitted_tid
  json.status trade.status
  json.status_text trade.status_text
  json.receiver_name trade.receiver_name
  json.receiver_mobile_phone trade.receiver_mobile_phone
  json.receiver_address trade.receiver_address
  json.receiver_district trade.receiver_district
  json.receiver_city trade.receiver_city
  json.receiver_state trade.receiver_state
  json.buyer_message trade.buyer_message
  json.buyer_nick trade.buyer_nick
  json.seller_memo trade.seller_memo
  json.has_split_deliver_bill trade.has_split_deliver_bill
  json.trade_source trade.trade_source
  json.created trade.created.strftime("%m-%d %H:%M") if trade.created
  json.created_timestamp trade.created.to_i if trade.created
  json.pay_time trade.pay_time.strftime("%m-%d %H:%M") if trade.pay_time
  json.cs_memo trade.cs_memo
  json.gift_memo trade.gift_memo
  json.deliver_bill_printed_at trade.deliver_bill_printed_at.try(:strftime, "%m-%d %H:%M")
  json.logistic_printed_at trade.logistic_printed_at.try(:strftime, "%m-%d %H:%M")
  json.has_color_info trade.has_color_info
  json.has_cs_memo trade.has_cs_memo
  json.has_unusual_state trade.has_unusual_state
  json.unusual_color_class trade.unusual_color_class if trade.unusual_color_class
  json.has_refund_order trade.has_refund_order
  json.can_change_logistic can_change_logistic(trade)
  json.invoice_type trade.invoice_type
  json.invoice_name trade.invoice_name
  json.invoice_content trade.invoice_content
  json.invoice_date trade.invoice_date.strftime("%Y-%m-%d") if trade.invoice_date
  json.invoice_value trade.payment
  json.payment trade.payment

  json.point_fee trade.point_fee
  json.total_fee trade.total_fee

  json.logistic_id trade.logistic_id
  json.logistic_name trade.logistic_name
  json.logistic_waybill trade.logistic_waybill
  json.seller_confirm_deliver_at trade.seller_confirm_deliver_at.strftime("%m-%d %H:%M") if trade.seller_confirm_deliver_at
  json.seller_confirm_invoice_at trade.seller_confirm_invoice_at.strftime("%m-%d %H:%M") if trade.seller_confirm_invoice_at
  json.confirm_color_at trade.confirm_color_at.strftime("%m-%d %H:%M") if trade.confirm_color_at
  json.confirm_check_goods_at trade.confirm_check_goods_at.strftime("%m-%d %H:%M") if trade.confirm_check_goods_at
  json.confirm_receive_at trade.confirm_receive_at.strftime("%m-%d %H:%M") if trade.confirm_receive_at
  json.request_return_at trade.request_return_at.strftime("%m-%d %H:%M") if trade.request_return_at
  json.confirm_return_at trade.confirm_return_at.strftime("%m-%d %H:%M") if trade.confirm_return_at
  json.confirm_refund_at trade.confirm_refund_at.strftime("%m-%d %H:%M") if trade.confirm_refund_at
  if trade.consign_time
    json.consign_time trade.consign_time.strftime("%m-%d %H:%M")
  else
    if trade.delivered_at
      json.consign_time trade.delivered_at.strftime("%m-%d %H:%M")
    end
  end

  json.dispatched_at trade.dispatched_at.strftime("%m-%d %H:%M") if trade.dispatched_at

  json.seller_id trade.seller_id
  json.seller_name trade.seller_name || trade.try(:seller).try(:name)

  json.orders OrderDecorator.decorate(trade.orders) do |json, order|
    json.id order._id
    json.title order.title
    json.num order.num
    json.cs_memo order.cs_memo
    json.color_num order.color_num
    json.color_hexcode order.color_hexcode
    json.color_name order.color_name
  end
end
