# -*- encoding:utf-8 -*-
require "csv"

desc "添加新商品"

# =======================
# OPTIONS:
#   - file_name: csv文件名
# =======================

task :add_products_to_sellers => :environment do
  Product.delete_all
  product_ids = []
  CSV.foreach("#{Rails.root}/lib/data_source/#{ENV['file_name']}") do |row|
    puts row[7]
    product = Product.create!(
      name: row[1],
      iid: row[7],
      storage_num: row[7]
    )

    product.category = Category.find_or_create_by_name row[0]
    product.quantity = Quantity.find_or_create_by_name row[2]
    product.save!
    product_ids << product.id
  end

  StockProduct.delete_all

  Seller.find_each do |seller|
    product_ids.each do |product_id|
      sp = seller.stock_products.create!(
        product_id: product_id,
        safe_value: 20,
        max: 99999,
        activity: 9000,
        actual: 9000
      )
    end
  end
end
