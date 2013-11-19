#encoding: utf-8
namespace :magic_order do
  desc "更新订单,顾客信息中的shop_name字段"
  task :update_trade_shop_name => :environment do
    Trade.where(:shop_name => nil).group(:trade_source_id).each do |h|
      trade_source_id = h["_id"]["trade_source_id"]
      trade_source = TradeSource.find_by_id(trade_source_id)
      if trade_source
        puts "[Trade] Updating... (#{trade_source.trade_type_name}) #{trade_source.name}"
        Trade.where(trade_source_id: trade_source_id).update_all(:shop_name => trade_source.name)
        puts "Done!"
      end
    end

    Customer.group(:account_id,:ec_name).each do |h|
      c = h["_id"]
      trade = Trade.where(account_id: c["account_id"],_type: c["ec_name"]).first
      if trade
        puts "[Customer] Updating... (#{trade.type_text}) #{trade.shop_name}"
        Customer.where(c).update_all(:shop_name => trade.shop_name,trade_source_id: trade.trade_source_id)
        puts "Done!"
      end
    end
  end
end