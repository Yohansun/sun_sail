# -*- encoding : utf-8 -*-
require 'fileutils'

class BrandsTaobaoTradeReporter
  include Sidekiq::Worker
  include BaseHelper
  sidekiq_options :queue => :reporter

  def perform(id)
    report = TradeReport.find(id)
    account = report.fetch_account
    current_user = User.find(report.user_id)
    hash = report.conditions
    hash = recursive_symbolize_keys! hash
    trades = Trade.filter(account, current_user, hash).order_by(:created.desc)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1[0, 0] = "订单列表"

    yellow_format = Spreadsheet::Format.new :pattern_bg_color => "yellow", :color => "black", :pattern_fg_color => "yellow", :pattern => 1
    blue_format = Spreadsheet::Format.new :pattern_bg_color => "blue", :color => "white", :pattern_fg_color => "blue", :pattern => 1
    title_format = Spreadsheet::Format.new :color => "blue", :weight => :bold, :size => 18
    bold = Spreadsheet::Format.new(:weight => :bold)

    row_number = 1
    
    header = ["订单来源", "订单编号", "当前状态", "下单时间", "付款时间", "支付宝到帐时间", "分流时间", "发货时间", "送货经销商", "买家地址-省", "买家地址-市", "买家地址-区", "买家地址", "买家姓名", "联系电话", "商品名",  "组合编码", "单品编码", "件数", "单品编码", "件数", "单品编码", "件数", "单品编码", "件数",  "数量", "商品标价", "商品总价（不含运费）",  "卖家优惠", "运费", "订单总金额", "买家旺旺", "买家留言", "整单备注", "单品备注", "发票信息", "商品属性" ,"退款状态", "买家评价结果", "评价内容", "评价时间", "vip优惠", "店铺优惠券", "店铺折扣", "优惠金额"]
    
    sheet1.row(1).concat(header)
     trades.each_with_index do |trade, trade_index|
      trade_orders = trade.orders
      trade_source = '淘宝'
      taobao_status_memo = trade.taobao_status_memo
      created = trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S")
      pay_time = trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S")
      end_time = trade.status == "TRADE_FINISHED" ? trade.end_time.try(:strftime,"%Y-%m-%d %H:%M:%S") : ''
      dispatched_at = trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
      delivered_at = trade.delivered_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
      taobao_status_memo = trade.taobao_status_memo
      seller = Seller.find_by_id(trade.seller_id)
      seller_name = trade.seller_name || trade.try(:seller).try(:name)
      receiver_state = trade.receiver_state
      receiver_city = trade.receiver_city
      receiver_district = trade.receiver_district
      receiver_address = trade.receiver_address
      receiver_name = trade.receiver_name
      receiver_mobile = trade.receiver_mobile
      buyer_nick = trade.buyer_nick
      buyer_message = trade.buyer_message
      tid = trade.splitted? ? trade.splitted_tid : trade.tid
      trade_cs_memo = trade.cs_memo
      invoice_name = trade.invoice_name
      sum_fee = trade.total_fee
      post_fee = trade.post_fee
      total_fee = trade.payment
      seller_discount = trade.promotion_fee || 0
      trade_orders.each_with_index do |order, order_index|

       if order_index != 0
        sum_fee = post_fee = total_fee =  seller_discount = ''
       end 

        title = order.title
        order_num = order.num
        order_price = order.price
        outer_iid = order.outer_iid
        sku_properties = order.sku_properties
        order_cs_memo = order.cs_memo
        refund_status_text = order.refund_status_text

        product = Product.find_by_num_iid order.num_iid

        refund_status_text = order.refund_status_text
        rate_content = rate_created = rate_result = ''
        rate = TaobaoTradeRate.where(oid: order.oid).first || TaobaoTradeRate.where(tid: trade.tid).first
        if rate
          rate_result = rate.result
          rate_content = rate.content
          rate_created = rate.created
        end


        row_number += 1 

        vip_discount = trade.promotion_details.where(oid: order.oid).where(promotion_id: /^shopvip/i).sum(&:discount_fee)
        shop_discount = trade.promotion_details.where(oid: order.oid).where(promotion_id: /^shopbonus/i).sum(&:discount_fee)
        other_discount = trade.promotion_details.where(oid: order.oid).where(promotion_id: /^(?!shopvip|shopbonus)/i).sum(&:discount_fee)
        
        body = [trade_source, tid, taobao_status_memo, created, pay_time, end_time, dispatched_at, delivered_at, seller_name,
                receiver_state, receiver_city, receiver_district, receiver_address, receiver_name, receiver_mobile, title, outer_iid, 
                product.try(:child_outer_id_at, 0), product.try(:child_number_at,0), product.try(:child_outer_id_at, 1), product.try(:child_number_at,1), 
                product.try(:child_outer_id_at, 2), product.try(:child_number_at,2), product.try(:child_outer_id_at, 3), product.try(:child_number_at,3), 
                order_num, order_price, sum_fee,  seller_discount, post_fee, total_fee, buyer_nick, buyer_message, trade_cs_memo,order_cs_memo, invoice_name, sku_properties,
                refund_status_text, rate_result, rate_content, rate_created, vip_discount, shop_discount, other_discount, (vip_discount+shop_discount+other_discount)]
        
        sheet1.row(row_number).concat(body)

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
