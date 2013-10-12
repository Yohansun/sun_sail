json.array!(@stock_bills) do |json,bill|
  json.tid      bill.tid
end