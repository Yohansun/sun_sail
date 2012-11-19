# -*- encoding:utf-8 -*-


desc "比对淘宝和新订单的数据_2"
task :compare_taobao_magic_2 => :environment do
  require 'csv'

  p "Start~~~~~~~~~~~~~~~~~~~~"

  open("10.18-11.10_magic_taobao_unmatch.csv", 'w+') do |csv|
  	open("#{Rails.root}/lib/tasks/double_ele_data/10.18-11.10_taobao_data.csv").readlines.each do |t_line|
			csv.write "淘宝id,淘宝实付金额,emall_id,emall实付金额"
			t_row = t_line.split(",")
			t_id = t_row[0].strip
			t_money = t_row[1].strip
			t = Trade.where(tid: t_id).first
            p t.id 
            p t_id
			if t.payment != t_money.to_f
	      	csv.write [t_id, t_money, t.id, t.payment].join(",")
	      	csv.write "\n"
	      	p tid
	      	p t.tid
	      	p money
            p t.payment
	    end
	  end
  end  
end