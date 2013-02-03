json.shopname TradeSetting.shopname
json.tid @trade.tid
json.status @trade.status_text
json.receiver_name @trade.receiver_name
json.receiver_mobile_phone @trade.receiver_mobile_phone
json.receiver_phone @trade.receiver_phone
json.receiver_state @trade.receiver_state
json.receiver_city @trade.receiver_city
json.receiver_district @trade.receiver_district
json.receiver_address @trade.receiver_address
json.cs_memo @trade.cs_memo
json.gift_memo @trade.gift_memo
json.logistic_name @trade.logistic_name
json.logistic_waybill @trade.logistic_waybill
json.notice TradeSetting.deliver_bill_notice_info
json.orders @bill.bill_products do |json, order|
  json.outer_id order.outer_id
  json.sku_name order.sku_name
  json.title order.title
  json.num order.number
  json.color_info order.color_info
  json.packaged order.packaged?
end
