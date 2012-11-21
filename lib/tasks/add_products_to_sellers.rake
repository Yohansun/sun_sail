# -*- encoding:utf-8 -*-

desc "添加新商品"
task :add_products_to_sellers => :environment do

  # 20121020
  # product_iids = ['ICI0054', 'ICI0056', 'ICI0059']

  Product.find_each do |product|
    puts "work with #{product.iid}"

    color_ids = product.color_ids
    puts 'begin add to sellers'

    Seller.find_each do |seller|
      sp = seller.stock_products.where(product_id: product.id).first

      unless sp
        sp = seller.stock_products.build(
          product_id: product.id,
          safe_value: 20
        )
      end

      sp.max = 99999
      sp.activity = 1000
      sp.actual = 1000

      if sp.save
        puts 'creat stock product success'
        sp.color_ids = color_ids
        puts 'set color success'
      end
    end

    puts product.iid + ' operation end'
  end
end
