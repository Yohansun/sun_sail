# -*- encoding : utf-8 -*-
task :lock_or_unlock_users => :environment do
	Seller.find_each do |seller|
		users = User.where(seller_id: seller.id)
		if seller.active
			users.each do |user| user.unlock_access! end
		else
			users.each do |user| user.lock_access! end	
		end
	end
end