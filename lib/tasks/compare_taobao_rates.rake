# -*- encoding:utf-8 -*-
task :compare_taobao_rates => :environment do
	open("lib/tasks/destination_rates.csv", 'w+') do |destination|
		destination.write "淘宝tid;是否评论;评分;评语内容 "
	  	open("lib/tasks/source_rate_tids.csv").readlines.each do |source|			
			row = source.split("-")
			tid = row[0].strip
			result = content = ''
			rate = TaobaoTradeRate.where(tid: tid).first
			if rate 
				result = rate.result
				content = rate.content.squish
			end
		      	destination.write [tid, result, content].join(";")
		      destination.write "\n"
		      	p tid
		end
	end	
end		
