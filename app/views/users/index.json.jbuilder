json.array!(@users) do |json, user|
  json.id user.id
  json.username user.username
  json.name user.name
  json.email user.email
end