# -*- encoding:utf-8 -*-


desc "比对淘宝和新订单的数据"
task :compare_taobao_magic => :environment do
  require 'csv'
  
	p "Start~~~~~~~~~~~~~~~~~~~~"
	t_row = []
	m_row = []
	CSV.foreach("#{Rails.root}/lib/tasks/double_ele_data/10.18-11.10_taobao_data.csv") do |t_line|
		t_row << t_line
	end	
		
	CSV.foreach("#{Rails.root}/lib/tasks/double_ele_data/10.18-11.10_magic_data.csv") do |m_line|
    m_row << m_line
  end

    p t_row
    p m_row
  
  CSV.open("10.18-11.10_magic_taobao_unmatch.csv", 'wb') do |csv|
	  extra_data = 0
	  (0...m_row.count).each do |i|
	    t_id = t_row[i][0].strip
	    p t_id
	    t_money = t_row[i][1].strip.to_f
	    p t_money

	    m_id = m_row[i - extra_data][0].strip
	    p m_id
	    m_money = m_row[i - extra_data][1].strip.to_f
	    p m_money
	    tmp_money = 0
	    count = 0
	    if t_id == m_id && t_money == m_money
	    elsif t_id == m_id && t_money != m_money
	      tmp_money += m_money
	      if tmp_money != t_money
	      	count++
	      	extra_data++
	      	csv << [t_id,t_money,m_id,m_money]
	      else
	        csv.pop(count)	
	      end
	    else
	      csv << [t_id,t_money,m_id,m_money]
	    end
	  end
  end  
end