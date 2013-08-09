# -*- encoding : utf-8 -*-
require "csv"

desc "Imports new product for ruilai"
task :import_new_product => :environment do
  puts '--- starting ---'
  account = Account.find 9
  Product.where(account_id: 9).each do |product|
    if product.destroy
      p"#{product.name} delete success!!"
    end
  end
  code = []
  name = []
  category = []
  File.open("#{Rails.root}/lib/data_source/ruilai_new_product.csv").readlines.each do |line|
    row = line.split(",")
    row[0].strip!
    code << row[0]
    row[1].strip!
    name << row[1]
    row[2].strip!
    category_id = account.categories.where(name: row[2]).first_or_create
    category << category_id.id
  end
  length = code.length
  (1..length).each do |index|
    new_product = Product.where(name: name[index-1]).first_or_create(account_id: 9, outer_id: code[index-1], category_id: category[index-1] )
    sku = new_product.skus.where(product_id: new_product.id, account_id: 9).first_or_create
    StockProduct.create(product_id: new_product.id, seller_id: account.sellers.first.id, sku_id: sku.id, account_id: account.id, max: 999999, safe_value: 20)
    p"#{name[index-1]} create success!!"
  end
end