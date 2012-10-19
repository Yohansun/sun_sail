#-*- encoding:utf-8 -*-
require "csv"

desc "重置订单状态"
task :reset_status => :environment do
  CSV.foreach("#{Rails.root}/lib/data_source/trade_to_change_1018.csv") do |row|
    puts "订单号 #{row[0]}"

    trade = nil
    trades = Trade.where(tid: row[0])
    if trades.size > 1
      puts '已拆单, 跳过'
      next
    else
      trade = trades.first
    end

    unless trade
      puts "订单未找到"
      next
    end

    trade.status = "WAIT_SELLER_SEND_GOODS"
    trade.save
  end
end
