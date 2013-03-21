# -*- encoding:utf-8 -*-
require "csv"

task :configure_sellers_users => :environment do
  account = Account.find_by_id(ENV['account_id'])
  break unless account
  CSV.foreach("#{Rails.root}/lib/tasks/sellers.csv") do |row|
    fullname  = row[0]  #经销商全称
    name      = row[1]  #经销商简称 
    username  = row[2] #登录名 
    password  = row[3] 
    interface_name = row[4] #销售部 
    role_name = row[5]

    seller = account.sellers.where(fullname: fullname, name: name).first_or_create!
    
    if interface_name.present?
      interface = account.sellers.where(fullname: interface_name, name: interface_name).first_or_create!
      seller.update_attributes!(parent_id: interface.id, interface: interface.name)
    end
    if username.present?
      email = "#{account.key}#{SecureRandom.hex(10)}@doorder.com"
      user = account.users.create!(username: username, name: username, email: email, password: password) unless user = account.users.where(username: username).first
      user.add_role role_name.to_sym
      seller.users = [user]
    end
    p "#{fullname} finished"
  end
end

task :configure_areas_sellers=> :environment do
  account = Account.find_by_id(ENV['account_id'])
  break unless account
  missing_area = missing_seller = [] 
  CSV.foreach("#{Rails.root}/lib/tasks/areas.csv") do |row|
    state_name  = row[0] 
    city_name   = row[1]  
    district_name  = row[2]
    seller_name  = row[3] 

    #based on third structure area

    state = Area.roots.find_by_name(state_name) if state_name.present?

    unless state
      p "state #{state_name} not found"
      missing_area << state_name
      next
    end

    city = state.children.find_by_name(city_name) if city_name.present?

    unless city
      p "city  #{state_name}#{city_name} not found"
      missing_area << "#{state_name}#{city_name}"
      next
    end

    district = city.children.find_by_name(district_name) if district_name.present?

    unless district
      p "district #{state_name}#{city_name}#{district_name} not found"
      missing_area << "#{state_name}#{city_name}#{district_name}"
      next
    end

    seller = account.sellers.where(name: seller_name).first
    
    unless seller
      missing_seller << seller_name
      p "seller #{seller_name} not found"
      next
    end  

    sellers = district.sellers || []
    sellers = sellers << seller
    selllers = sellers.uniq
    district.sellers = sellers
    
    p "#{state_name}#{city_name}#{district_name} finished"
  end
  p missing_area
  p missing_seller
end

task :configure_stocks => :environment do
  account = Account.find_by_id(ENV['account_id'])
  break unless account 
  products = account.products 
  break unless products.present? 
  sellers = account.sellers.where("parent_id IS NOT NULL")
  break unless sellers.present?
  sellers.update_all(has_stock: true, stock_opened_at: Time.now)
  sellers.each do |seller|
    products.each do |product|
      skus = product.skus
      break unless skus.present? 
      skus.each do |sku|
        next if seller.stock_products.where(account_id: account.id, product_id: sku.product_id, num_iid: sku.num_iid,  sku_id: sku.id).exists?
        seller.stock_products.create!(account_id: account.id, product_id: sku.product_id, safe_value:20, max:9000, activity:1000, actual:1000, sku_id:sku.id, num_iid: sku.num_iid)
      end
    end    
  end
end


task :batch_reconfigure_sellers => :environment do
  CSV.foreach("#{Rails.root}/lib/tasks/sellers.csv") do |row|
    seller_id     = row[0] #经销商id
    old_fullname  = row[1] #经销商全称 
    new_fullname  = row[2] #修正后经销商全称 
    old_name      = row[3] #经销商简称 
    new_name      = row[4] #修正后经销商简称 
    old_username  = row[5] #登录名 
    new_username  = row[6] #修正后登录名 
    old_interface = row[7] #销售部 
    new_interface = row[8] #修正后销售部
    
    seller = Seller.find_by_id(seller_id)
    unless seller
      p "seller_id #{seller_id} not exist"
      next
    end
    
    #seller.update_attributes!(fullname: new_fullname) if new_fullname.present? && new_fullname != old_fullname
    seller.update_attributes!(name: new_name) if new_name.present? #&& new_name != old_name

    if new_interface.present? && new_interface != old_interface
      interface = Seller.find_by_name(new_interface)
      seller.parent = interface
      seller.save
    end 

    if new_username.present? && new_username != old_username 
      user = User.find_by_username(old_username)
      user.username = new_username
      user.name = new_username
      user.save
    end  
  end
end

task :batch_reconfigure_special_stocks => :environment do
  #Product id: 264, name: "净享居竹炭五合一 套装 1套"
  product_id = ENV['product_id']
  CSV.foreach("#{Rails.root}/lib/tasks/stocks.csv") do |row|
   seller_name = row[0]
   number = row[1].to_i
   operation = row[2]
   note = row[3]
   seller = Seller.find_by_name(seller_name)
   if seller
     stock = seller.stock_products.where(product_id: product_id).first
     stock = seller.stock_products.new(product_id: product_id, max: 99999, safe_value: 20) unless stock
     stock.activity = stock.activity + number
     stock.actual = stock.actual + number
     if stock.save(validate: false)
       stock_history = StockHistory.new
       stock_history.operation = operation
       stock_history.number = number
       stock_history.stock_product_id = stock.id
       stock_history.user_id = 6
       stock_history.seller_id = stock.seller_id
       stock_history.note = note
       stock_history.reason = 'o0'
       stock_history.save(validate: false) 
     else
       p "seller #{seller.name} update stock false"
     end  
   else
     p "seller #{seller_name} not found"
   end
 end 
end