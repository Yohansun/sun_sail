# encoding:utf-8
desc "生成测试订单"
task :build_test_trades => :environment do

	a = [
    'A1P14L20048C0W01',
    'I1P18L50060C4V03',
    'I1P18L50061C4V04',
    'I1P18L40062C4V03',
    'I1P04L10028C0V01',
    'I1P04L10026C0V01',
    'I1P04L10027C0V01',
    'I1P04L10056C0V00',
    'I1P04L10058C0V01',
    'I1P18L50102C4V07',
    'I1P02L10105C4V04',
    'I1P04L10106C0V01',
    'I1P18L20110C4V04',
    'A1P14L20111C0W03',
    'I1P18L20109C4V03',
    'I1P18L10112C4V03',
    'I1P04L10095C0V01',
    'O1P04L10113C0V00',
    'O1P21L60114C0V00',
    'O1P21L60115C0V00',
    'O1P21L60116C0V00',
    'O1P21L60117C0V00'
  ]

  b = ['I1P18L40063C4V04']


  or_trade_tids = []

  count = 0

		
	Product.where("iid not in (?)", (a | b)).each do |p|

		trade = TaobaoPurchaseOrder.skip(count).first
		while trade.orders.size > 1
			count += 1
			trade = TaobaoPurchaseOrder.skip(count).first
		end

		or_trade_tids << trade.tid
		trade.receiver["district"] = '通川区'
		trade.receiver["city"] = '达州市'
		trade.receiver["stat"] = '四川省'
		trade.status = 'WAIT_SELLER_SEND_GOODS'
		trade.seller_id = nil
		trade.seller_name = nil
		trade.dispatched_at = nil

		order = trade.orders.first
		order.title = "测试商品#{p.iid}"
		order.item_outer_id = p.iid
		order.color_num = nil
		
		order.save
		trade.save

		count += 1
	end

	sp_trade_tids = []

	Product.where("iid in (?)", a).each do |p|

		trade = TaobaoPurchaseOrder.skip(count).first
		while trade.orders.size > 1
			count += 1
			trade = TaobaoPurchaseOrder.skip(count).first
		end

		sp_trade_tids << trade.tid
		trade.receiver["district"] = '莲湖区'
		trade.receiver["city"] = '西安市'
		trade.receiver["stat"] = '陕西省'
		trade.status = 'WAIT_SELLER_SEND_GOODS'
		trade.seller_id = nil
		trade.seller_name = nil
		trade.dispatched_at = nil

		order = trade.orders.first
		order.title = "测试商品#{p.iid}"
		order.item_outer_id = p.iid
		order.color_num = nil
		
		order.save
		trade.save

		count += 1
	end

	areas = [['福建省','福州市','闽侯区'], ['辽宁省','沈阳市','皇姑区'], ['上海','上海市','闵行区'], ['河南省','三门峡市','湖滨区']]

	sp_area_tids = []
	product = Product.find_by_iid 'I1P18L40063C4V04'
	return unless product

	areas.each do |area|
		trade = TaobaoPurchaseOrder.skip(count).first
		while trade.orders.size > 1
			count += 1
			trade = TaobaoPurchaseOrder.skip(count).first
		end

		sp_area_tids << trade.tid
		trade.receiver["district"] = area[2]
		trade.receiver["city"] = area[1]
		trade.receiver["stat"] = area[0]
		trade.status = 'WAIT_SELLER_SEND_GOODS'
		trade.seller_id = nil
		trade.seller_name = nil
		trade.dispatched_at = nil

		order = trade.orders.first
		order.title = "测试商品#{product.iid}"
		order.item_outer_id = product.iid
		order.color_num = nil
		order.save
		trade.save

		count += 1
	end

	puts sp_area_tids.inspect
	puts sp_trade_tids.inspect
	puts or_trade_tids.inspect
end