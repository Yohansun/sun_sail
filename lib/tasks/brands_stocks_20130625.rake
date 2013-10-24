# -*- encoding : utf-8 -*-
require 'csv'
task :update_brands_stocks => :environment do
  CSV.foreach("#{Rails.root}/lib/tasks/brands/brands_stocks_20130827.csv") do |row|
    outer_id = row[0]
    actual = row[1]
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
      stock.update_attributes(actual: actual, activity: actual)
      p "#{outer_id} after #{stock.actual}"
    else
      p "product not found #{outer_id}"
    end
  end
end
task :gnc_stocks_20130821 => :environment do
  CSV.foreach("#{Rails.root}/gnc.csv") do |row|
    outer_id = row[0].present? ? row[0].to_s.strip : 0
    name = row[1]
    tmall_number = row[2].to_i
    jd_number = row[3].to_i
    yhd_number = row[4].to_i

    account = Account.find 10

    tmall_seller = account.sellers.where(trade_type: "Taobao").first
    jd_seller = account.sellers.where(trade_type: "Jingdong").first
    yhd_seller = account.sellers.where(trade_type: "Yihaodian").first

    product = account.products.find_by_outer_id(outer_id)
    if product
    else
      product = account.products.create!(name: name, outer_id: outer_id)
    end
    sku = product.skus.first

    unless sku
      sku = product.skus.create(account_id: account.id, product_id: product.id, num_iid: product.num_iid)
    end

    tmall_stock = StockProduct.where(product_id: product.id, seller_id: tmall_seller.id, sku_id: sku.id, num_iid: product.num_iid, account_id: account.id).first_or_create
    tmall_stock.update_attributes(actual: tmall_number, activity: tmall_number)

    jd_stock = StockProduct.where(product_id: product.id, seller_id: jd_seller.id, sku_id: sku.id, num_iid: product.num_iid, account_id: account.id).first_or_create
    jd_stock.update_attributes(actual: jd_number, activity: jd_number)

    yhd_stock = StockProduct.where(product_id: product.id, seller_id: yhd_seller.id, sku_id: sku.id, num_iid: product.num_iid, account_id: account.id).first_or_create
    yhd_stock.update_attributes(actual: yhd_number, activity: yhd_number)
  end
end
task :richlife_stocks_20130821 => :environment do
  CSV.foreach("#{Rails.root}/lib/tasks/richlife_stocks_20130821.csv") do |row|
    outer_id = row[0].to_s.rjust(6, '0')
    name = row[1]
    number = row[2]
    account = Account.find 9
    seller = account.sellers.first
    product = account.products.find_by_outer_id(outer_id)
    if product
      puts product.name + '-------' + name
      sku = product.skus.first
      unless sku
        sku = product.skus.create(account_id: account.id, product_id: product.id, num_iid: product.num_iid)
      end
      stock = StockProduct.where(product_id: product.id, seller_id: seller.id, sku_id: sku.id, num_iid: product.num_iid, account_id: account.id).first_or_create
      stock.update_attributes(actual: number, activity: number)
    else
      p "product not found #{outer_id}"
    end
  end
end

task :batch_modify_stocks => :environment do
  file = ENV['file']
  account_id = ENV['account_id']
  account = Account.find account_id
  seller = account.sellers.first

  CSV.foreach("#{file}") do |row|
    outer_id = row[0].strip
    number = row[1].strip
    product = account.products.find_by_outer_id(outer_id)
    if product
      sku = product.skus.first
      unless sku
        sku = product.skus.create(account_id: account.id, product_id: product.id, num_iid: product.num_iid)
      end
      stock_product = StockProduct.where(product_id: product.id, seller_id: seller.id, sku_id: sku.id, num_iid: product.num_iid, account_id: account.id).first_or_create

      change = stock_product.actual.to_i - number.to_i

      puts "--------------------------------"
      puts outer_id + ',' + change.to_s

      next if change == 0

      if change > 0
        bill = StockOutBill.new(stock_typs: "VIRTUAL", status: "STOCKED", confirm_stocked_at: Time.now, seller_id: seller.id ,account_id: account_id)
        changed = change
      else
        bill = StockInBill.new(stock_typs: "VIRTUAL", status: "STOCKED", confirm_stocked_at: Time.now, seller_id: seller.id ,account_id: account_id)
        changed = change * -1
      end

      bill.bill_products.build(stock_product_id: stock_product.id, title: sku.title, outer_id: product.outer_id, sku_id: sku.id, price: 0, total_price: 0, number: changed)
      bill.bill_products_mumber = bill.bill_products.sum(:number)
      bill.bill_products_price = 0
      bill.save!


      puts  bill.as_json

      if change > 0
        bill.decrease_activity
        bill.decrease_actual
      else
        bill.sync_stock
      end

    else
      p "product not found #{outer_id}"
    end
  end
end