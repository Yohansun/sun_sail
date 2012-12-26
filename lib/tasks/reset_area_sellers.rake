# encoding: utf-8
desc "重新绑定经销商"
task :reset_area_sellers => :environment do
	Area.find_each do |area|
		seller_ids = area.seller_ids
		seller = Seller.find_by_id area.seller_id
		unless seller
			next
		end
		seller_ids = (seller_ids & [1791,1792,1793,1794]) << area.seller_id
		area.seller_ids = seller_ids
		area.save
	end
end