json.list(@bills) do |json, bill|
  trade = TradeDecorator.decorate(bill.trade)
  json.template_path current_account.deliver_template.try(:xml_url) || "/ffd.xml"
  json.bills_count @bills_count
  json.id bill.id
  json.trade_id bill.trade_id
  json.tid trade.tid
  json.trade_type trade._type.gsub('Trade','').downcase
  json.bill_number bill.deliver_bill_number
  json.is_printed bill.deliver_printed_at.present? ? "发货单已打印" : "发货单未打印"
  json.is_logistic_printed bill.logistic_printed_at.present?
  json.is_process_sheet_printed bill.process_sheet_printed_at.present? ?  "工艺单已打印" : "工艺单未打印"
  json.receiver_name trade.receiver_name
  json.buyer_nick trade.buyer_nick
  json.receiver_mobile trade.receiver_mobile
  json.receiver_address trade.receiver_address
  json.trade_source trade.trade_source
  json.logistic_name trade.logistic_name
  json.logistic_waybill trade.logistic_waybill
  json.delivered_at trade.delivered_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
  json.orders bill.bill_products do |json, order|
    json.outer_id order.outer_id
    json.outer_sku_id order.outer_sku_id
    json.sku_name order.sku_name
    json.title order.title
    json.num order.number
    json.cs_memo order.memo
    json.color_info order.color_info
  end
end

json.counter_cache counter_caches(current_account.id)