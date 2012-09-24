# -*- encoding : utf-8 -*-

desc "重构areas 一对多经销商"
task :rebuild_areas => :environment do
	Area.find_each do |area|
		seller = Seller.find_by_id area.seller_id
		if seller
			area.seller_ids = area.seller_ids | [area.seller_id]
		end
	end
end