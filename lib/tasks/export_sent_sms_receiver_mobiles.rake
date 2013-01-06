# -*- encoding : utf-8 -*-
task :export_sent_sms_receiver_mobiles => :environment  do

	mobiles = []	
	Trade.all.each do |trade|
		logs = trade.operation_logs
		next if logs.size < 1
		logs.each do |log|
			next unless log.operation.include?("短信")
			next if log.operation.include?("失败")
			mobile = log.operation.gsub('发送短信到', '').gsub('发送付款成功短信到买家手机', '').gsub('发送发货短信到买家手机', '').gsub('发送物流评分短信到买家手机', '')
			mobiles << mobile 
		end
	end

	CSV.open('lib/tasks/export_uniq_sent_sms_receiver_mobiles.csv', 'wb') do |csv|
		mobiles.each  do |mobile|
			csv << [mobile]
		end
	end


end