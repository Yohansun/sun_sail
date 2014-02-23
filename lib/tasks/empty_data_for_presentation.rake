# -*- encoding : utf-8 -*-

desc "清空奔跑的南瓜王店铺演示数据"
task :empty_data_for_presentation => :environment do

  account = Account.find_by_name("科勒旗舰店")
  account.update_attributes(name: "奔跑的南瓜王")

  p "清空淘宝商品"
  account.taobao_products.delete_all
  account.taobao_skus.delete_all

  p "清空本地商品"
  account.products.delete_all

  p "清空绑定数据"
  account.skus.delete_all

  p "清空库存"
  account.stock_products.delete_all

  p "清空订单及订单相关数据"
  account.trades.delete_all
  DeliverBill.where(account_id: account.id).delete_all
  StockInBill.where(account_id: account.id).delete_all
  StockOutBill.where(account_id: account.id).delete_all
  TradePropertyMemo.where(account_id: account.id).delete_all
end