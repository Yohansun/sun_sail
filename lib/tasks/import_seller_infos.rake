# -*- encoding : utf-8 -*-
require "csv"
desc "导入Sellers数据"
task :import_seller_infos => :environment do

  open("#{Rails.root}/lib/tasks/sellers_infos.csv").readlines.each do |line|
    row = line.split(";")
    seller_id = row[0].strip
    name = row[1].strip
    mobile = row[2].strip
    telephone = row[3].strip
    cc_emails = row[4].strip
    email = row[5].strip
    seller = Seller.find(seller_id)
    if seller && seller.name == name
      seller.update_attributes(:mobile => mobile, :telephone => telephone, :cc_emails => cc_emails, :email => email)
      puts "已修改#{name},email#{email},cc_emails#{cc_emails}"
    end
  end

end