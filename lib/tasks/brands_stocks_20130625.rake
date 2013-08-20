# -*- encoding : utf-8 -*-
require 'csv'
task :brands_stocks_20130625 => :environment do
  CSV.foreach("#{Rails.root}/lib/tasks/brands/brands_stocks_20130625.csv") do |row|
    outer_id = row[0]
    activity = row[1]
    actual = row[2]
    account = Account.find 2
    seller = account.sellers.first
    product = Product.find_by_outer_id(outer_id)
    if product
      sku = product.skus.first
      unless sku
        sku = product.skus.create(account_id: account.id, product_id: product.id, num_iid: product.num_iid)
      end
      stock = StockProduct.where(product_id: product.id, seller_id: seller.id, sku_id: sku.id, num_iid: product.num_iid, account_id: account.id).first_or_create
      p "#{outer_id} before #{stock.actual}"
      stock.update_attributes(actual: actual, activity: activity)
      p "#{outer_id} after #{stock.actual}"
    else
      p "product not found #{outer_id}"
    end
  end
end

task :gnc_stocks_20130821 => :environment do
  CSV.foreach("#{Rails.root}/lib/tasks/gnc_stocks_20130821.csv") do |row|
    outer_id = row[0].to_s.rjust(6, '0')
    name = row[1]
    number = row[2]
    account = Account.find 10
    seller = account.sellers.first
    product = account.products.find_by_outer_id(outer_id)
    if product
      puts product.name + '-------' + name
      sku = product.skus.first
      unless sku
        sku = product.skus.create(account_id: account.id, product_id: product.id, num_iid: product.num_iid)
      end
      stock = StockProduct.where(product_id: product.id, seller_id: seller.id, sku_id: sku.id, num_iid: product.num_iid, account_id: account.id).first_or_create
      stock.update_attributes(actual: number, activity: number, forecast: number)
    else
      p "product not found #{outer_id}"
    end
  end
end