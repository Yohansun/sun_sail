json.id @trade.id
json.tid @trade.tid
json.seller_id @trade.seller_id
json.status @trade.status
json.status_text @trade.status_text
json.receiver @trade.receiver
json.trade_source @trade.trade_source
json.memo @trade.memo
json.post_fee @trade.post_fee
json.total_fee @trade.total_fee
json.created @trade.created.strftime("%m-%d %H:%M")
json.pay_time @trade.pay_time.strftime("%m-%d %H:%M") if @trade.pay_time
json.consign_time @trade.consign_time.strftime("%m-%d %H:%M") if @trade.consign_time

json.orders @trade.orders do |json, order|
  json.item_id order.item_id
  json.title order.title
  json.auction_price order.auction_price
  json.num order.num
  json.buyer_payment order.buyer_payment
  json.distributor_payment order.distributor_payment
  json.total_fee order.total_fee
  json.price order.price
  json.sku_properties order.sku_properties
  json.item_outer_id order.item_outer_id
end