json.array!(@bill_products) do |json,product|
  json.outer_id product.outer_id
  json.title  product.title
  json.outer_id product.outer_id
  json.num_iid  product.num_iid
  json.sku_id product.sku_id
  json.stock_product_id product.stock_product_id
  json.sku_code product.sku.try(:sku_id)
end