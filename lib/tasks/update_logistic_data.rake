# -*- encoding:utf-8 -*-

desc "更新配送商数据"
task :update_logistic_data => :environment do
	if Logistic.find_by_id 1 != nil
	  @logi = Logistic.find_by_id 1 
	  @logi.update_attributes(name: "其他")
	else
	  @logi = Logistic.create(name: "其他")
	end
	@logi.save
	p @logi.name
	p "Succeed!"
end	