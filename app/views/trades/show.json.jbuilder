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
json.buyer_message @trade.buyer_message
json.seller_memo @trade.seller_memo
json.post_fee @trade.post_fee
json.total_fee @trade.total_fee
json.created @trade.created.strftime("%m-%d %H:%M")
json.pay_time @trade.pay_time.strftime("%m-%d %H:%M") if @trade.pay_time

json.cs_memo @trade.cs_memo                                                            # 买家备注

json.logistic_code @trade.logistic_code
json.logistic_company @trade.logistic_company
json.logistic_waybill @trade.logistic_waybill

json.invoice_type @trade.invoice_type                                                  # 发票信息
json.invoice_name @trade.invoice_name
json.invoice_date @trade.invoice_date.strftime("%Y-%m-%d") if @trade.invoice_date

if @trade.consign_time
  json.consign_time @trade.consign_time.strftime("%m-%d %H:%M")
else
  if @trade.delivered_at
    json.consign_time @trade.delivered_at.strftime("%m-%d %H:%M")
  end
end

json.orders OrderDecorator.decorate(@trade.orders) do |json, order|
  json.id order._id
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
  json.cs_memo order.cs_memo
  json.color_num order.color_num
end