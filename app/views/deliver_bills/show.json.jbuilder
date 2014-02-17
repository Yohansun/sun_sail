json.shopname @trade.seller_nick
json.bill_number @bill.deliver_bill_number
json.is_process_sheet_printed @bill.process_sheet_printed_at.present? ?  "工艺单已打印" : "工艺单未打印"
json.tid @trade.tid
json.status @trade.status_text
json.buyer_nick @trade.buyer_nick
json.seller_nick @trade.seller_nick
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
json.notice current_account.settings.deliver_bill_notice_info
json.orders @bill.bill_products do |json, order|
  json.id order.id
  json.outer_id order.outer_id
  json.outer_sku_id order.outer_sku_id
  json.sku_name order.sku_name
  json.title order.title
  json.num order.number
  json.color_info order.color_info
  json.promotion_desc ""
  json.price ""
  json.payment ""
  json.created @trade.created.strftime("%Y-%m-%d")
end
json.product_num @bill.bill_products.sum(:number)
json.real_product_num @bill.except_ref_bills.sum(:number)
json.total_payment ""
json.post_fee ""
json.total ""
json.company_name @trade.fetch_account.settings.company_name
json.company_phone @trade.fetch_account.settings.company_phone
json.company_address @trade.fetch_account.settings.company_address
json.print_date Time.now.strftime("%Y-%m-%d")
json.bill_products_count @bill.bill_products.try(:count).to_i
json.trade_type @trade._type
json.template_path current_account.deliver_template.try(:xml_url) || "/ffd.xml"
json.ref_orders @bill.except_ref_bills do |json, order|
  json.id order.id
  json.outer_id order.outer_id
  json.outer_sku_id order.outer_sku_id
  json.sku_name order.sku_name
  json.title order.title
  json.num order.number
  json.color_info order.color_info
  json.promotion_desc ""
  json.price ""
  json.payment ""
  json.created @trade.created.strftime("%Y-%m-%d")
end