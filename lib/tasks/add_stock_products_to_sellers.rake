# -*- encoding:utf-8 -*-
require "csv"

task :add_each_sku_to_sellers => :environment do
  account_id = ENV['account_id']  
  Seller.where(account_id: account_id).find_each do |seller|
    Sku.find_each do |sku|
     next if  seller.stock_products.where(product_id: sku.product_id, num_iid: sku.num_iid,  sku_id: sku.id).exists?
     seller.stock_products.create!(
        product_id: sku.product_id,
        safe_value: 20,
        max: 9000,
        activity: sku.quantity,
        actual:  sku.quantity,
        sku_id: sku.id,
        num_iid: sku.num_iid
      )
    end
  end
end

task :add_bml_stock_products_from_csv => :environment do
  account = Account.find_by_id(ENV['account_id'])
  break unless account
  seller = account.sellers.first
  break unless seller
  CSV.foreach("#{Rails.root}/lib/tasks/skus.csv") do |row|
    customer_id = row[0]
    outer_id    = row[1]  
    name        = row[2]
    actual      = row[3]
    safe_value  = row[4]  
    activity    = row[5]    
    product = Product.find_by_outer_id(outer_id)
    next unless product
    if product.good_type == 2
       p "metion good_type 2 #{outer_id}"
       products = product.package_products
       products.each do |sp|
        sku = sp.skus.first
        next unless sku
        seller.stock_products.create(
        product_id: sku.product_id,
        safe_value: safe_value,
        max: 99999999,
        activity: activity,
        actual:  actual,
        sku_id: sku.id,
        num_iid: sku.num_iid
        )  
       end 
    else
      sku = product.skus.first
      next unless sku
      seller.stock_products.create(
      product_id: sku.product_id,
      safe_value: safe_value,
      max: 99999999,
      activity: activity,
      actual:  actual,
      sku_id: sku.id,
      num_iid: sku.num_iid
      )  
    end    
  end
end