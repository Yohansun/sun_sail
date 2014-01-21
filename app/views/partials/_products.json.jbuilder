json.array!(@products) do |json,product|
  json.id      product.id
  json.sku_id      product.sku_id
  json.title_with_product_id  product.title_with_product_id
end