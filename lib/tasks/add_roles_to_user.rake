# -*- encoding : utf-8 -*-

desc "为用户添加roles"
task :add_roles_to_user => :environment do
	User.find_each do |user|
		case user.role_level
    when 0
      user.add_role :admin
    when 10
      user.add_role :seller
    when 12
      user.add_role :interface
    when 15
      user.add_role :cs
    end
	end
end