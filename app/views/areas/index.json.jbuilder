json.array!(@areas) do |json, area|
  json.id area.id
  json.name area.name
  json.zip area.zip
  json.children_count area.children_count
  if area.seller
    json.seller_id area.seller.id
    json.seller_name area.seller.name
  end
end