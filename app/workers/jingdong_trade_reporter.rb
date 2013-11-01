# -*- encoding : utf-8 -*-
require 'fileutils'

class JingdongTradeReporter
  include Sidekiq::Worker
  sidekiq_options :queue => :reporter, unique: true, unique_job_expiration: 120

  def perform(id)
    report = TradeReport.find(id)
    return unless report
    account = report.fetch_account
    if report.batch_export_ids
      trades = Trade.where(:_id.in => report.batch_export_ids.split(',')).order_by(:created.desc)
    else
      trades = report.trades.order_by(:created.desc)
    end
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1[0, 0] = "订单列表"

    odd_format = Spreadsheet::Format.new  :pattern_bg_color => "white", :color => "black", :pattern_fg_color => "white", :pattern => 1
    even_format = Spreadsheet::Format.new :pattern_bg_color => "gray", :color => "white", :pattern_fg_color => "gray", :pattern => 1
    title_format = Spreadsheet::Format.new :weight => :bold, :size => 18
    bold = Spreadsheet::Format.new(:weight => :bold)

    row_number = 1

    header = ["订单来源",
              "订单编号",
              "当前状态",
              "下单时间",
              "付款时间",
              "分派时间",
              "发货时间",
              "交易完成时间",             #读取交易关闭的时间
              "发货仓库",                #读取发货仓库名
              "买家地址-省",
              "买家地址-市",
              "买家地址-区",
              "买家地址",
              "买家姓名",
              "买家昵称",
              "买家手机",
              "买家座机",
              "商品名",
              "商品数量",
              "物流商",
              "物流单号"]

    header += [ #"商品单价",              #读取淘宝该商品原价
                "商品售价",               #读取淘宝该商品市场价
                #"商品优惠",               #读取商品优惠
                #"订单优惠",               #除“商品优惠”外的其他优惠的总和
                "商品实付价",
                "运费",                   #读取运费，如果一笔订单里商品多，则只要显示在第一行就好
                "订单总金额",              #读取订单的总金额，如果一笔订单里商品多，则只要显示在第一行就好
                # "订单实付金额",            #读取订单的实付金额，如果一笔订单里商品多，则只要显示在第一行就好
                #"多退金额",
                #"少补金额",
                "买家留言",
                "客服备注",
                "单品备注",
                "赠品备注",
                "发票信息",
                "商品属性",
                "退款状态",
                #"买家评价结果",
                #"评价内容",
                #"评价时间"
                ]


    sheet1.row(1).concat(header)
     trades.each_with_index do |trade, trade_index|
      trade_source = trade.type_text
      tid = trade.order_id
      jingdong_status_memo = trade.status_name
      created = trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S")
      pay_time = trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S")
      dispatched_at = trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
      delivered_at = trade.delivered_at.try(:strftime,"%Y-%m-%d %H:%M:%S") || trade.consign_time.try(:strftime,"%Y-%m-%d %H:%M:%S")
      end_time = (trade.status == "FINISHED_L" ? trade.end_time.try(:strftime,"%Y-%m-%d %H:%M:%S") : '')
      stock_name = "默认仓库"

      post_fee = trade.post_fee
      trade_total_fee = trade.total_fee
      trade_payment = trade.payment
      seller_discount = trade.seller_discount || 0 #no show
      #trade_add_ref_money = trade.ref_batches.where(ref_type: 'add_ref').first.ref_payment rescue nil
      #trade_return_ref_money = -(trade.ref_batches.where(ref_type: 'return_ref').last.ref_payment) rescue nil

      receiver_state = trade.province
      receiver_city = trade.city
      receiver_district = trade.county
      receiver_address = trade.full_address
      receiver_name = trade.fullname
      buyer_nick = trade.buyer_nick
      receiver_mobile = trade.mobile
      receiver_phone = trade.telephone

      buyer_message = trade.order_remark
      trade_cs_memo = trade.cs_memo
      trade_gift_memo = trade.gift_memo
      invoice_name = trade.invoice_info

      #物流信息
      logistic_name = trade.logistic_name
      logistic_waybill = trade.logistic_waybill

      trade_orders = trade.orders

      trade_orders.each_with_index do |order, order_index|
        if order_index != 0
         post_fee = trade_total_fee = trade_payment = vip_discount = shop_discount = shop_bonus = other_discount = ''
        end

        title = order.title
        order_num = order.num
        price = order.price
        #商品原价order_price = order.order_price
        sku_properties = order.sku_properties
        order_cs_memo = order.cs_memo
        refund_status_text = order.refund_status_text

        # order_discount_fee = (order.discount_fee/order_num).to_f.round(2)
        # trade_discount_fee = (price - order_price - order_discount_fee).to_f.round(2)
        # order_payment = order.order_payment


        row_number += 1

        body = [trade_source,              #读取订单平台来源
                tid,                       #读取淘宝订单编号或拆分订单编号
                jingdong_status_memo,      #读取订单当前状态
                created,                   #读取订单下单时间
                pay_time,                  #读取订单付款时间
                dispatched_at,             #读取系统最后一次分派时间
                delivered_at,              #读取系统进行发货的时间
                end_time,                  #读取交易关闭的时间
                stock_name,                #读取发货仓库名
                receiver_state,            #读取订单买家地址-省
                receiver_city,             #读取订单买家地址-市
                receiver_district,         #读取订单买家地址-区
                receiver_address,          #读取订单买家地址
                receiver_name,             #读取买家姓名
                buyer_nick,                #读取买家旺旺
                receiver_mobile,           #读取买家联系电话-手机
                receiver_phone,            #读取买家联系电话-座机
                title,                     #读取商品名
                order_num,                 #读取商品数
                logistic_name,             #读取物流商，没有的话为空
                logistic_waybill]          #读取物流单号，没有的话为空

        body +=[price,                       #读取淘宝该商品市场价
                # order_price,                 #读取淘宝该商品原价
                # order_discount_fee,           #读取商品优惠
                # trade_discount_fee,          #除“商品优惠”外的其他优惠的总和
                # order_payment,
                post_fee,                    #读取运费，如果一笔订单里商品多，则只要显示在第一行就好
                trade_total_fee,             #读取订单的总金额，如果一笔订单里商品多，则只要显示在第一行就好
                trade_payment,               #读取订单的实付金额，如果一笔订单里商品多，则只要显示在第一行就好
                #trade_add_ref_money,         #读取订单的少补货金额
                #trade_return_ref_money,      #读取订单的多退货金额
                buyer_message,               #读取买家留言，没有的话为空
                trade_cs_memo,               #读取客服备注，没有的话为空
                order_cs_memo,               #读取单品备注，没有的话为空
                trade_gift_memo,             #读取赠品备注，没有的话为空
                invoice_name,                #读取发票信息，没有的话为空
                sku_properties,              #读取商品属性，没有的话为空
                refund_status_text,          #读取退款状态，没有的话为空 读取VIP优惠，没有的话为空
                ]


        sheet1.row(row_number).concat(body)


        if trade_index.even?
          sheet1.row(row_number).default_format = even_format
        else
          sheet1.row(row_number).default_format = odd_format
        end
      end
    end


    file = "#{Rails.root}/data/#{id}.xls"
    book.write file
    report.update_attributes!(performed_at: Time.now)
  end
end
