json.array!(@trades) do |json, trade|
  json.id trade.id
  json.tid trade.tid
  json.status trade.status
  json.receiver trade.receiver
  json.trade_source trade.trade_source
  json.created trade.created
end