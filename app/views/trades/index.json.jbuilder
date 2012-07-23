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
  json.seller_memo trade.seller_memo
  json.cs_memo trade.cs_memo
  json.trade_source trade.trade_source
  json.created trade.created.strftime("%m-%d %H:%M")
  json.pay_time trade.pay_time.strftime("%m-%d %H:%M") if trade.pay_time

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
end