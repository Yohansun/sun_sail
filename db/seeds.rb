# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u = User.new(email: "admin@doorder.com", password: "doorder", password_confirmation: "doorder", name: 'admin', username: 'admin')
u.save!
u.add_role :admin

#生成本地订单的顾客信息
CustomersPuller.initialize!