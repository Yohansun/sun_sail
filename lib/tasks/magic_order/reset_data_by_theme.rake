#encoding: utf-8
desc "达利的店铺从1月1日开始正式上线，现在还需要系统做一些准备"
namespace :magic_order do
  task :reset_data_by_theme => :environment do
    account_id = 26

    scope = Trade.where(account_id: account_id,created: {"$lte" => "2014-01-01 00:00:00 +0800".to_time(:local)})
    # 删除相关出入库单
    StockBill.where(:tid.in => scope.distinct(:tid)).delete_all
    # 清空达利账户所有订单相关数据
    scope.delete_all
    # 清空达利账户数据魔方中的历史数据；
    TradeReport.where(account_id: account_id).delete_all
    # 清空达利账户相关退货单
    RefundProduct.where(account_id: account_id).delete_all
    # 清空达利账户下的所有顾客信息
    Customer.where(account_id: account_id).delete_all
  end
end