# -*- encoding : utf-8 -*-
require 'fileutils'

class NipponOtherTradeReporter
  include Sidekiq::Worker
  include BaseHelper
  sidekiq_options :queue => :reporter

  def perform(id)
    report = TradeReport.find(id)
    current_user = User.find(report.user_id)
    hash = report.conditions
    hash = recursive_symbolize_keys! hash
    trades = Trade.filter(current_user, hash).order_by(:created.desc)
    trades = TradeDecorator.decorate(trades)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1[0, 0] = "订单列表"


    yellow_format = Spreadsheet::Format.new :pattern_bg_color => "yellow", :color => "black", :pattern_fg_color => "yellow", :pattern => 1
    blue_format = Spreadsheet::Format.new :pattern_bg_color => "blue", :color => "white", :pattern_fg_color => "blue", :pattern => 1
    title_format = Spreadsheet::Format.new :color => "blue", :weight => :bold, :size => 18
    bold = Spreadsheet::Format.new(:weight => :bold)

    row_number = 1
     sheet1.row(1).concat ["订单来源", "订单编号", "当前状态", "下单时间", "付款时间", "分流时间", "发货时间", "客户姓名", "联系电话", "联系地址", "客户留言", "卖家备注", "客服备注", "调色信息", "发票信息", "配送经销商", "店铺代码(分销)", "主订单号(分销)", "商品名称", "单价（实际销售）", "数量", "运费", "订单实付金额" ,"退款状态"]
     trades.each_with_index do |trade, trade_index|
      if trade._type == "TaobaoPurchaseOrder"
        tc_order_id = trade.tc_order_id
        distributor_usercode = trade.distributor_usercode
      end
      trade_orders = OrderDecorator.decorate(trade.orders)
      trade_source = trade.trade_source
      status_text = trade.status_text
      created = trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S")
      pay_time = trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S")
      dispatched_at = trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
      delivered_at = trade.delivered_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
     seller_name = seller_name trade.seller_name || trade.try(:seller).try(:name)
      seller_memo = trade.seller_memo
      receiver_state = trade.receiver_state
      receiver_city = trade.receiver_city
      receiver_district = trade.receiver_district
      receiver_address = trade.receiver_address
      receiver_name = trade.receiver_name
      receiver_mobile_phone = trade.receiver_mobile_phone
      buyer_nick = trade.buyer_nick
      buyer_message = trade.buyer_message
      has_color_info = trade.has_color_info
      tid = trade.splitted? ? trade.splitted_tid : trade.tid
      trade_cs_memo = trade.cs_memo
      invoice_name = trade.invoice_name
      post_fee = trade.post_fee
      total_fee = trade.total_fee
      trade_orders.each do |order|
        order_price = order.price
        order_title = order.title
        order_num = order.num
        color_num = order.color_num
        cs_memo = "#{trade_cs_memo} #{order.cs_memo}"
        refund_status_text = order.refund_status_text
        row_number += 1
        sheet1.update_row row_number, trade_source, tid, status_text, created, pay_time, dispatched_at, delivered_at, receiver_name, receiver_mobile_phone, receiver_address, seller_memo, buyer_message, cs_memo, color_num, invoice_name, seller_name, distributor_usercode, tc_order_id, order_title, order_price, order_num, post_fee, total_fee, refund_status_text

        if trade_index.even?
          sheet1.row(row_number).default_format = yellow_format
        else
          sheet1.row(row_number).default_format = blue_format
        end
      end
    end

    file = "#{Rails.root}/data/#{id}.xls"
    book.write file
    report.update_attributes!(performed_at: Time.now)
  end
end
