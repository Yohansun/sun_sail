# -*- encoding:utf-8 -*-

desc "如果仓库名称为空，让仓库名称等于经销商名"
task :update_seller_stock_name => :environment do
  Seller.update_all("stock_name=name", "stock_name IS NULL OR stock_name = ''")
end