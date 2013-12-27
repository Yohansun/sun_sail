#encoding: utf-8
namespace :magic_order do
  desc "更新账户人工订单默认的类型"
  task :init_trade_type_setting => :environment do
    Account.find_each do |account|
      account.add_trade_type_setting if account.settings.trade_types.nil?
    end
  end
end