json.array!(@users) do |json, user|
  json.id user.id
  json.username user.username
  json.name user.name
  json.email user.email
  json.roles user.roles.map{|role| role.name}
  json.active user.active
end