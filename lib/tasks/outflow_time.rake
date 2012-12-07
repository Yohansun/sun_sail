#-*- encoding:utf-8 -*-
require "csv"

task :outflow_time => :environment do
  CSV.open("outflow_you.csv", 'wb') do |csv|
	  CSV.foreach("#{Rails.root}/lib/data_source/outflow_time.csv") do |row|
	    t_time = Trade.where(tid: row[0]).first.confirm_receive_at
	    if t_time
	      time = t_time.to_time.strftime("%Y-%m-%d %H:%M:%S")
	    end
	    csv << [time]
	    p time
	  end
	end
end