json.array!(@areas) do |json, area|
  json.id area.id
  json.name area.name
  json.zip area.zip
  json.children_count area.children_count
end