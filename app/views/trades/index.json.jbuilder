json.array!(@trades) do |json, trade|
  json.id trade._id
  json.tid trade.tid
  json.status trade.status
  json.status_text trade.status_text
  json.receiver_name trade.receiver_name
  json.receiver_mobile_phone trade.receiver_mobile_phone
  json.receiver_address trade.receiver_address
  json.receiver_district trade.receiver_district
  json.receiver_city trade.receiver_city
  json.receiver_state trade.receiver_state
  json.buyer_message trade.buyer_message
  json.seller_memo trade.seller_memo
  json.trade_source trade.trade_source
  json.created trade.created.strftime("%m-%d %H:%M") if trade.created
  json.pay_time trade.pay_time.strftime("%m-%d %H:%M") if trade.pay_time

  json.cs_memo trade.cs_memo                                                                  # 买家备注

  json.has_color_info trade.has_color_info                                                    # 判断调色信息是否存在
  
  json.invoice_type trade.invoice_type                                                        # 发票信息
  json.invoice_name trade.invoice_name
  json.invoice_date trade.invoice_date.strftime("%Y-%m-%d") if trade.invoice_date
  
  if trade.consign_time
    json.consign_time trade.consign_time.strftime("%m-%d %H:%M")
  else
    if trade.delivered_at
      json.consign_time trade.delivered_at.strftime("%m-%d %H:%M")
    end
  end

  json.dispatched_at trade.dispatched_at.strftime("%m-%d %H:%M") if trade.dispatched_at

  json.seller_id trade.seller_id
  json.seller_name trade.seller.name if trade.seller

  json.orders OrderDecorator.decorate(trade.orders) do |json, order|
    json.id order._id
    json.title order.title
    json.num order.num
    json.cs_memo order.cs_memo
    json.color_num order.color_num
  end
end