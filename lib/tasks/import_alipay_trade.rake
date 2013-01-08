# -*- encoding : utf-8 -*-
require "csv"

desc "Imports the trade data from Alipay CSV file. 
  Usage: bundle exec rake import_alipay_trade file=2012110100-2012111500"
task :import_alipay_trade => :environment do
  puts '--- starting ---'
  # file = File.open("#{Rails.root}/lib/data_source/alipay_trade/#{ENV['file']}.csv", "r:gbk")
  # index = 0
  # CSV.parse(file) do |row|
  #   break if row[0].include?("账务明细列表结束")
  #   if index > 4
  #     ath = AlipayTradeHistory.new
  #     ath.finance_trade_sn = row[0]
  #     ath.business_trade_sn = row[1]
  #     ath.merchant_trade_sn = row[2]
  #     ath.product_name = row[3].encode('UTF-8') if row[3]
  #     ath.traded_at = row[4]
  #     ath.account_info = row[5].encode('UTF-8') if row[5]
  #     ath.revenue_amount = row[6]
  #     ath.outlay_amount = row[7]
  #     ath.balance_amount = row[8]
  #     ath.trade_source = row[9].encode('UTF-8') if row[9]
  #     ath.trade_type = row[10].encode('UTF-8') if row[10]
  #     ath.memo = row[11].encode('UTF-8') if row[11]
  #     ath.save
  #     puts '.'
  #   end
  #   index += 1
  # end

  # revenues_data = AlipayTradeHistory.revenues
  # rs = ReconcileStatement.new(trade_store_source: 'Alipay', trade_store_name: '和宝尊')
  # rs.detail = ReconcileStatementDetail.new
  # rs.audit_time = revenues_data.first.traded_at
  # rs.save
  # revenues_data.each do |trade|
  #   AlipayTradeOrder.create(
  #     reconcile_statement_id: rs.id,
  #     alipay_trade_history_id: trade.id,
  #     original_trade_sn: trade.merchant_trade_sn,
  #     trade_sn: trade.merchant_trade_sn.split("P").last.gsub(/\t/, ''),
  #     traded_at: trade.traded_at)
  # end

  rs     = ReconcileStatement.first
  rs_detail = rs.detail
  orders = AlipayTradeOrder.where(["reconcile_statement_id = ?", rs.id])
  tids   = orders.map(&:trade_sn)
  trades = Trade.in(tid: tids)
  rs_detail.alipay_revenue = rs_detail.postfee_revenue = 0
  trades.each do |trade|
    rs_detail.alipay_revenue  += trade.total_fee
    rs_detail.postfee_revenue += trade.post_fee
  end
  rs_detail.save
  puts '--- finished ---'
end