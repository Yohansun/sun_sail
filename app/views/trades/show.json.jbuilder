json.id @trade._id
json.tid @trade.tid
json.seller_id @trade.seller_id
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
json.seller_memo @trade.seller_memo
json.post_fee @trade.post_fee
json.total_fee @trade.total_fee
json.created @trade.created.strftime("%m-%d %H:%M")
json.pay_time @trade.pay_time.strftime("%m-%d %H:%M") if @trade.pay_time
json.consign_time @trade.consign_time.strftime("%m-%d %H:%M") if @trade.consign_time


json.orders OrderDecorator.decorate(@trade.orders) do |json, order|
  json.title order.title
  json.num order.num
  json.total_fee order.total_fee
  json.price order.price
  json.item_id order.item_id
  json.sku_properties order.sku_properties
  json.auction_price order.auction_price
  json.buyer_payment order.buyer_payment
  json.distributor_payment order.distributor_payment
  json.item_outer_id order.item_outer_id
end
