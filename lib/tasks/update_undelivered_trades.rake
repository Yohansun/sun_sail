# -*- encoding:utf-8 -*-
require "csv"

desc "更新淘宝上未发货的订单"
task :fetch_undelivered_trades => :environment do
  tmp = []
  CSV.foreach("#{Rails.root}/lib/data_source/undelivered_trades_02.csv") do |row|
    tid = row[0]
    trade = TaobaoTrade.where(tid: tid).first

    if trade.blank?
      puts "#{row[0]} not found"
      tmp << tid
      next
    end

    unless trade.status == 'WAIT_BUYER_CONFIRM_GOODS'
      puts "#{row[0]} 不可发货"
      tmp << tid
      next
    end

    response = TaobaoQuery.get(
      {
        method: 'taobao.logistics.offline.send',
        tid: trade.tid,
        out_sid: trade.logistic_waybill,
        company_code: trade.logistic_code
      }, 
      trade.trade_source_id
    )

    errors = response['error_response']
    code = errors.present?

    unless code
      tmp << tid
    end
  end

  puts tmp
end
