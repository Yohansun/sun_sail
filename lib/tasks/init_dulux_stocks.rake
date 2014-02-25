# -*- encoding:utf-8 -*-

desc "多乐士官方旗舰店初始化库存数据"
task :init_dulux_stocks => :environment do
  account = Account.find_by_name("多乐士官方旗舰店")

  p "清空库存"
  account.stock_products.delete_all

  account.sellers.find_each do |seller|
    account.skus.each do |sku|
      p "添加库存 " + seller.name + " " + sku.product.name
      account.stock_products.create(
        max: 999999,
        safe_value: 20,
        activity: 500,
        actual: 500,
        product_id: sku.product_id,
        seller_id: seller.id,
        sku_id: sku.id,
        num_iid: sku.num_iid
      )
    end
  end
end