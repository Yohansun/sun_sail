#encoding: utf-8
namespace :magic_order do
  # http://git.networking.io/nioteam/magic_orders/merge_requests/2676/diffs
  desc "BUG #895 【Magic Order】仓库管理-出库单 锁定&激活 可用库存的加减问题 引用方法如果传入的参数block为空的话,导致判断错误"
  task :bug_895 => :environment do
    StockOutBill.search(:created_at_gt => '2013-11-08 21:40:21' ,:status_eq => "STOCKED").each do |out|
      out.decrease_activity
      out.decrease_actual
    end
  end
end