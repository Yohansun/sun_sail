# -*- encoding:utf-8 -*-
require 'csv'
desc "删除商品的调色信息"
task :delete_color_content => :environment do
  color_id_array=[]
  CSV.foreach("#{Rails.root}/lib/data_source/color.2012.11.27.csv") do |row|
    name = row[1] 
    num = row[0]
    p name
    c = Color.find_by_name(name).delete
    p "Succeed!"
  end
end