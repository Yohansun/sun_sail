# -*- encoding:utf-8 -*-
require "csv"

desc "录入多乐士颜色"
task :fill_color_data_for_dulux => :environment do
  color_red = []
  color_all = []
  Color.delete_all

  CSV.foreach("#{Rails.root}/lib/data_source/color_20121013.csv") do |row|
    color = Color.new(
      num: row[0],
      name: row[1],
      hexcode: row[2]
    )

    color.save

    if row[3] != '红色'
      color_red << color.id
    end

    color_all << color.id
  end

  puts 'color import ok'
  p color_red.inspect
  p color_all.inspect

  StockProduct.delete_all

  Seller.find_each do |seller|
    Product.find_each do |product|
      stock_product = StockProduct.new(
        max: 99999,
        safe_value: 10,
        product_id: product.id,
        seller_id: seller.id
      )

      product.color_ids = color_all
      stock_product.color_ids = color_red
      stock_product.save!
    end

    seller.has_stock = true
    seller.stock_opened_at = Time.now
    seller.save!
  end

  puts "seller set products ok"

  seller = Seller.find_by_name '多乐士经销商'
  return unless seller

  seller.stock_products.each do |sp|
    sp.color_ids = color_all
    sp.actual = 99999
    sp.activity = 99999
    sp.save!
  end

  puts "多乐士仓库 ok"

  Area.find_each do |area|
    area.seller_ids += [seller.id]
  end

  puts '多乐士仓库 set area ok'
end
