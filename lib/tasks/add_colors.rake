# -*- encoding:utf-8 -*-
require 'csv'
desc "import colors"
task :import_colors => :environment do
  tmp = []
  CSV.foreach("#{Rails.root}/lib/tasks/import_colors.csv") do |row|
    	
      puts "STARTING~~~~~~~~~~~~~~~~~~~~"
    	hexcode = row[0] #? row[0].force_encoding("UTF-8"):nil
    	name = row[1] #? row[1].force_encoding("UTF-8"):nil
    	num = row[2]
      
      p name
      
    	c = Color.new(
    		:hexcode => hexcode,
    		:name => name,
    		:num => num
    		)
      
      unless c.save
        tmp << name
        puts "#{c.errors.inspect}"
      else
        p "Succeed!"
      end

  end

  CSV.open("colorfailedtasks_20120725.csv", 'wb') do |csv|
    tmp.each {|f| csv << [f]}
  end
	
end