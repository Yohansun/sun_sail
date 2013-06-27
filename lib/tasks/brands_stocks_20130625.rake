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
      stock.update_attributes(max: 999999, actual: actual, activity: activity, safe_value: 20)
    else
      p "product not found #{outer_id}"
    end
  end
end