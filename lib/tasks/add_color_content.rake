# -*- encoding:utf-8 -*-
require 'csv'
desc "增加商品的调色信息"
task :add_color_content => :environment do
  color_id_array=[]
  CSV.foreach("#{Rails.root}/lib/data_source/color.2012.11.27.csv") do |row|
    puts "进行中..."
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
      color_id_array << c.id
      p "Succeed!"
    end
  end
    Product.find_each do |product|
      color_ids = product.color_ids
      product.color_ids = color_ids | color_id_array
      p "product Succeed#{color_ids}"
    end
end