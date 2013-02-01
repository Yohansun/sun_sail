# -*- encoding:utf-8 -*-
require "csv"

desc "添加新商品"

# =======================
# OPTIONS:
#   - file_name: csv文件名
# =======================

task :add_stock_products_to_sellers => :environment do
  Seller.find_each do |seller|
    Sku.find_each do |sku|
     next if  seller.stock_products.where(product_id: sku.product_id, num_iid: sku.num_iid).exists?
     p seller.id
     p sku.sku_id 
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
