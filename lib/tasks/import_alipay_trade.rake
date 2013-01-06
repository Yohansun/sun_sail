# -*- encoding : utf-8 -*-
require "csv"

desc "Imports the trade data from Alipay CSV file. 
  Usage: bundle exec rake import_alipay_trade file=2012110100-2012111500"
task :import_alipay_trade => :environment do
  puts '--- starting ---'
  file = File.open("#{Rails.root}/lib/data_source/alipay_trade/#{ENV['file']}.csv", "r:gbk")
  index = 0
  CSV.parse(file) do |row|
    break if row[0].include?("账务明细列表结束")
    if index > 4
      ath = AlipayTradeHistory.new
      ath.finance_trade_sn = row[0]
      ath.business_trade_sn = row[1]
      ath.merchant_trade_sn = row[2]
      ath.product_name = row[3].encode('UTF-8') if row[3]
      ath.traded_at = row[4]
      ath.account_info = row[5].encode('UTF-8') if row[5]
      ath.revenue_amount = row[6]
      ath.outlay_amount = row[7]
      ath.balance_amount = row[8]
      ath.trade_source = row[9].encode('UTF-8') if row[9]
      ath.trade_type = row[10].encode('UTF-8') if row[10]
      ath.memo = row[11].encode('UTF-8') if row[11]
      ath.save
      puts '.'
    end
    index += 1
  end
  puts '--- finished ---'
end