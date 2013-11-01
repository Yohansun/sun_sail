# -*- encoding : utf-8 -*-

class ReconcileStatementDetailReporter
  include Sidekiq::Worker
  include ReconcileStatementDetailsHelper
  sidekiq_options :queue => :reporter, :retry => false, unique: true, unique_job_expiration: 120

  def perform(rs_detail_id, money_type)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1[0, 0] = "对账详情数据"

    info_array = judge_money_type_th(money_type)
    rsd = ReconcileStatementDetail.find(rs_detail_id)
    rs = rsd.reconcile_statement
    sheet1.row(1).concat(["订单编号", "订单来源", "顾客姓名", "送货地址"] + info_array + ["到账日期", "订单状态"])

    TradeDecorator.decorate(rsd.select_trades("default")).each_with_index do |trade, i|
      info_array = judge_money_type_td(trade, money_type)
      import_array = [trade.tid, trade.trade_source, trade.receiver_name, trade.receiver_address, info_array, trade.pay_time.strftime("%Y-%m-%d"), trade.status_text].flatten
      sheet1.row(i+2).concat(import_array)
    end

    title_format = Spreadsheet::Format.new(:color => :blue, :weight => :bold, :size => 14)
    sheet1.row(0).set_format(0, title_format)
    bold = Spreadsheet::Format.new(:pattern_fg_color => :yellow, :weight => :bold)
    sheet1.row(1).default_format = bold

    file = "#{Rails.root}/public/rsd_data/#{rs.audit_time.strftime('%Y-%m') +'-'+ money_type_text(money_type)}.xls"
    book.write file
    rs.exported[money_type.to_sym] = true
    rs.save
  end
end