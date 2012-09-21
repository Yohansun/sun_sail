# -*- encoding:utf-8 -*-

task :add_product_reference_data => :environment do
	Feature.create(name: "净味功能")
	Feature.create(name: "弹性抗裂功能")
	Feature.create(name: "抗甲醛功能")
	Feature.create(name: "荷净抗污功能")
	Feature.create(name: "专业调色功能")
	Feature.create(name: "清漆油性")
	Feature.create(name: "白漆油性")
	Feature.create(name: "高光")
	Feature.create(name: "半光")
	Feature.create(name: "亚光")
	Feature.create(name: "底漆")

	Level.create(name: "低档")
	Level.create(name: "中档")
	Level.create(name: "高档")

	Quantity.create(name: "5L")
	Quantity.create(name: "10L")

	Category.create(name: "网络特供商品")
	Category.create(name: "内墙乳胶漆")
	Category.create(name: "外墙乳胶漆")
	Category.create(name: "木器漆")
	Category.create(name: "DIY色彩系列")
	Category.create(name: "輔助材料")
end	

