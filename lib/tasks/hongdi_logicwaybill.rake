#-*- encoding:utf-8 -*-
require "csv"

desc "导入物流信息"
task :hongdi_logicwaybill => :environment do
  CSV.foreach("#{Rails.root}/lib/data_source/hongdi_logicwaybill.csv") do |row|
    next if row[2].blank?

    tid = row[0]
    waybill = row[1]

    trade = Trade.where(tid: tid).first
    return unless trade
    
    if trade.update_attributes(logistic_waybill: waybill,logistic_code: 'OTHER',logistic_company: '虹迪')
      puts tid
    end

    trade.operation_logs.create(
      operated_at: Time.now,
      operation: "虹迪发货单号#{waybill}, 发货时间#{row[2]}, 预计送达#{row[3]}"
    )
  end
end
