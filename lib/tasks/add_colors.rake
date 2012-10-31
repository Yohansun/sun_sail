# -*- encoding:utf-8 -*-
require 'csv'
desc "import colors"
task :import_colors => :environment do
  CSV.foreach("#{Rails.root}/lib/tasks/import_colors_20121031.csv") do |row|
    puts "STARTING~~~~~~~~~~~~~~~~~~~~"
  	name = row[1] 
  	num = row[0]
    
    p name
    
  	c = Color.new(
  		:name => name,
  		:num => num
  	)
    
    unless c.save
      puts "#{c.errors.inspect}"
    else
      p "Succeed!"

      Product.find_each do |p|
        color_ids = p.color_ids
        p.color_ids = color_ids + [c.id]

        p.stock_products.each do |s|
          color_ids = s.color_ids
          s.color_ids = color_ids + [c.id]
        end
      end
    end
  end
end
