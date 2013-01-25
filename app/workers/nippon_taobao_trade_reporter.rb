# -*- encoding : utf-8 -*-
require 'fileutils'

class NipponTaobaoTradeReporter
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
    if TradeSetting.enable_module_colors == true
      header = ["订单来源", "订单编号", "当前状态", "下单时间", "付款时间", "分流时间", "发货时间", "送货经销商", "接口人", "买家地址-省", "买家地址-市", "买家地址-区", "买家地址", "买家姓名", "联系电话", "商品名", "数量", "商品标价", "单品总价", "商品总价（不含运费）",  "卖家优惠", "运费", "订单总金额", "买家旺旺", "买家留言", "客服备注", "发票信息", "需要调色", "色号"]
    else
      header = ["订单来源", "订单编号", "当前状态", "下单时间", "付款时间", "分流时间", "发货时间", "送货经销商", "接口人", "买家地址-省", "买家地址-市", "买家地址-区", "买家地址", "买家姓名", "联系电话", "商品名", "数量", "商品标价", "单品总价", "商品总价（不含运费）",  "卖家优惠", "运费", "订单总金额", "买家旺旺", "买家留言", "客服备注", "发票信息"]
    end
    sheet1.row(1).concat(header)
     trades.each_with_index do |trade, trade_index|
      trade_orders = trade.orders
      trade_source = '淘宝'
      taobao_status_memo = trade.taobao_status_memo
      created = trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S")
      pay_time = trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S")
      dispatched_at = trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
      delivered_at = trade.delivered_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
      taobao_status_memo = trade.taobao_status_memo
      seller = Seller.find_by_id(trade.seller_id)
      interface_name = seller.try(:interface_name)
      seller_name = trade.seller_name
      receiver_state = trade.receiver_state
      receiver_city = trade.receiver_city
      receiver_district = trade.receiver_district
      receiver_address = trade.receiver_address
      receiver_name = trade.receiver_name
      receiver_mobile = trade.receiver_mobile
      buyer_nick = trade.buyer_nick
      buyer_message = trade.buyer_message
      if TradeSetting.enable_module_colors == true
        has_color_info = trade.has_color_info
      end
      tid = trade.splitted? ? trade.splitted_tid : trade.tid
      trade_cs_memo = trade.cs_memo
      invoice_name = trade.invoice_name
      sum_fee = trade.total_fee
      post_fee = trade.post_fee
      total_fee = trade.payment
      seller_discount = trade.promotion_fee
      trade_orders.each do |order|
        title = order.title
        order_num = order.num
        if TradeSetting.enable_module_colors == true
          color_num = order.color_num
        end
        order_price = order.price
        cs_memo = "#{trade_cs_memo} #{order.cs_memo}"
        if TradeSetting.enable_module_colors == true
          if order.color_num.present?
            color_num = order.color_num.join(",")
          else
            color_num = ''
          end
          need_color = has_color_info ? '是' : '否'
        end
        row_number += 1
        if TradeSetting.enable_module_colors == true
          sheet1.update_row row_number, trade_source, tid, taobao_status_memo, created, pay_time, dispatched_at, delivered_at, seller_name, interface_name, receiver_state, receiver_city, receiver_district, receiver_address, receiver_name, receiver_mobile, 
          title, order_num, order_price, sum_fee,  seller_discount, post_fee, total_fee, buyer_nick, buyer_message, cs_memo, invoice_name, need_color, color_num
        else
          sheet1.update_row row_number, trade_source, tid, taobao_status_memo, created, pay_time, dispatched_at, delivered_at, seller_name, interface_name, receiver_state, receiver_city, receiver_district, receiver_address, receiver_name, receiver_mobile, 
          title, order_num, order_price, sum_fee,  seller_discount, post_fee, total_fee, buyer_nick, buyer_message, cs_memo, invoice_name
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
