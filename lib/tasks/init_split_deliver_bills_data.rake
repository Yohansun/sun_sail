desc "初始化拆分发货单所需数据"

task :init_split_deliver_bill_data => :environment do
	TradeSetting.enable_trade_deliver_bill_spliting = true
  TradeSetting.enable_trade_deliver_bill_spliting_sellers = [1720]
end