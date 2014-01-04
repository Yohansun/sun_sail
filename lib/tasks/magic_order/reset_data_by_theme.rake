#encoding: utf-8
desc "达利的店铺从1月1日开始正式上线，现在还需要系统做一些准备"
namespace :magic_order do
  task :reset_data_by_theme => :environment do
    account_id = ENV["ACCOUNT_ID"] || 26

    scope = Trade.where(account_id: account_id,created: {"$lte" => "2014-01-01 00:00:00 +0800".to_time(:local)})

    exists_tids = Trade.where(account_id: account_id).distinct(:tid)
    # 删除无订单关联的出入库单
    StockBill.where(account_id: account_id, :tid.nin => exists_tids).delete_all
    # 删除对应发货单
    DeliverBill.where(account_id: account_id, :tid.in => scope.distinct(:tid)).delete_all
    # 清空达利账户指定条件的订单数据
    scope.delete_all
    # 清空达利账户数据魔方中的历史数据；
    TradeReport.where(account_id: account_id).delete_all
    # 清空达利账户相关退货单
    RefundProduct.where(account_id: account_id).delete_all
    # 清空达利账户下的所有顾客信息
    Customer.where(account_id: account_id).delete_all
  end
end