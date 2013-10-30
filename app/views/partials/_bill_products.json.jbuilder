json.array!(@bill_products) do |json,product|
  json.outer_id product.outer_id
  json.title  product.title
  json.outer_id product.outer_id
  json.num_iid  product.num_iid
  json.sku_id product.sku_id
  json.stock_product_id product.stock_product_id
  json.sku_code product.sku.try(:sku_id)
  json.tid  @bill.tid
  json.buyer_name  @bill.op_name
  json.op_state  @bill.op_state
  json.op_city  @bill.op_city
  json.op_district  @bill.op_district
  json.address  @bill.op_address
  json.phone  bill.op_phone
  json.mobile  @bill.op_mobile
  json.zip  @bill.op_zip
end	
