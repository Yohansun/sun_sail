# -*- encoding:utf-8 -*-

desc "导出交易还未成功订单数据"
task :export_unfinished_trade => :environment do
  account = Account.find_by_name("多乐士官方旗舰店")

  unknown_trades = []
  CSV.foreach("#{Rails.root}/import_unfinished_dulux_trade.csv") do |row|
    tid = row[0]
    p "导出订单#{tid}"
    trade = account.trades.where(tid: tid).first
    if trade.present?
      trade.update_attributes(JSON.parse(row[1]))
    else
      unknown_trades << tid
    end
  end

  if unknown_trades.present?
    p "这些订单并没有被抓取到，或者可能是多乐士线下订单或拆分订单" + unknown_trades.join(",")
  end
end