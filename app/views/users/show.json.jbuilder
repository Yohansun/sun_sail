json.id @user.id
json.username @user.username
json.name @user.name
json.email @user.email
json.is_support @user.has_role?('support')
json.is_seller @user.has_role?('seller')
json.is_interface @user.has_role?('interface')
json.is_stock_admin @user.has_role?('stock_admin')
json.roles @user.roles.map{|role| role.name}
json.active @user.active