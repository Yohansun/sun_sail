# -*- encoding : utf-8 -*-
require 'fileutils'

class DuluxTaobaoTradeReporter
  include Sidekiq::Worker
  include BaseHelper
  sidekiq_options :queue => :reporter

  def perform(id)
    report = TradeReport.find(id)
    current_user = User.find(report.user_id)
    hash = report.conditions
    hash = recursive_symbolize_keys! hash
    trades = Trade.filter(current_user, hash).order_by(:created.desc)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1[0, 0] = "订单列表"

    yellow_format = Spreadsheet::Format.new :pattern_bg_color => "yellow", :color => "black", :pattern_fg_color => "yellow", :pattern => 1
    blue_format = Spreadsheet::Format.new :pattern_bg_color => "blue", :color => "white", :pattern_fg_color => "blue", :pattern => 1
    title_format = Spreadsheet::Format.new :color => "blue", :weight => :bold, :size => 18
    bold = Spreadsheet::Format.new(:weight => :bold)

    row_number = 1
    if current_user.has_role?(:cs) || current_user.has_role?(:admin)
      sheet1.row(1).concat ["订单号", "下单时间", "付款时间", "分流时间", "订单状态", "送货经销商", "买家地址-省", "买家地址-市", "买家地址-区", "买家地址", "买家姓名", "收货人手机/座机", "商品名", "数量", "商品标价",  "订单金额", "卖家优惠", "运费", "订单总金额", "调整金额", "买家旺旺", "客服备注", "需要调色", "色号", "唯一码" ,"退款状态", "买家评价结果", "评价内容", "评价时间"]
    elsif current_user.has_role?(:seller) || current_user.has_role?(:logistic)
      sheet1.row(1).concat ["订单号", "下单时间", "付款时间", "分流时间", "订单状态", "送货经销商", "买家地址-省", "买家地址-市", "买家地址-区", "买家地址", "买家姓名", "收货人手机/座机", "商品名", "数量", "运费", "买家旺旺", "客服备注", "需要调色", "色号","唯一码","退款状态", "买家评价结果", "评价内容", "评价时间"]
    end
    trades.each_with_index do |trade, trade_index|
      trade_orders = trade.orders
      sum_fee = trade.total_fee
      post_fee = trade.post_fee
      total_fee = trade.payment
      modify_payment = trade.modify_payment
      seller_discount = trade.promotion_fee
      created = trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S")
      pay_time = trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S")
      dispatched_at = trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
      taobao_status_memo = trade.taobao_status_memo
      seller_name = trade.seller_name
      receiver_state = trade.receiver_state
      receiver_city = trade.receiver_city
      receiver_district = trade.receiver_district
      receiver_address = trade.receiver_address
      receiver_name = trade.receiver_name
      receiver_mobile = trade.receiver_mobile
      buyer_nick = trade.buyer_nick
      has_color_info = trade.has_color_info
      splitted_tid = trade.splitted_tid
      tid = trade.tid
      trade_cs_memo = trade.cs_memo
      trade_orders.each_with_index do |order, i|
        order_price = order.price
        num = order.num
        order_cs_memo = order.cs_memo
        cs_memo = "#{trade_cs_memo} #{order_cs_memo}"
        title = order.title
        color_num = ''
        color_num = order.color_num.join(" ") if order.color_num.present?
        barcodes = ''
        barcodes = order.barcode.join(" ") if order.barcode.present?
        need_color = has_color_info ? '是' : '否'
        refund_status_text = order.refund_status_text
        rate_content = rate_created = rate_result = ''
        rate = TaobaoTradeRate.where(oid: order.oid).first || TaobaoTradeRate.where(tid: trade.tid).first
        if rate
          rate_result = rate.result
          rate_content = rate.content 
          rate_created = rate.created
        end  
        row_number += 1
        if current_user.has_role?(:cs) || current_user.has_role?(:admin)
          sheet1.update_row row_number, tid, created, pay_time, dispatched_at, taobao_status_memo, seller_name, receiver_state, receiver_city, receiver_district, receiver_address, receiver_name, receiver_mobile, title, num, order_price,  sum_fee, seller_discount, post_fee, total_fee, modify_payment, buyer_nick, cs_memo, need_color, color_num, barcodes, refund_status_text,rate_result,rate_content,rate_created
        elsif current_user.has_role?(:seller) || current_user.has_role?(:logistic)
          sheet1.update_row row_number, tid, created, pay_time, dispatched_at, taobao_status_memo, seller_name, receiver_state, receiver_city, receiver_district, receiver_address, receiver_name, receiver_mobile, title, num, 0, buyer_nick, cs_memo, need_color, color_num, barcodes, refund_status_text,rate_result,rate_content,rate_created
        end
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
