json.array!(@trades) do |json, trade|
  json.id trade.id
  json.tid trade.tid
  json.status trade.status
  json.receiver trade.receiver
  json.trade_source trade.trade_source
  json.created trade.created.strftime("%m-%d %H:%M")
  json.pay_time trade.pay_time.strftime("%m-%d %H:%M") if trade.pay_time
  json.consign_time trade.consign_time.strftime("%m-%d %H:%M") if trade.consign_time
end