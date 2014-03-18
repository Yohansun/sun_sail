# -*- encoding : utf-8 -*-
require 'fileutils'

class TaobaoTradeReporter
  include Sidekiq::Worker
  sidekiq_options :queue => :reporter, unique: true, unique_job_expiration: 120

  def perform(id, user = nil)

##### 根据报表信息筛选订单

    report = TradeReport.where(_id: id).first or return
    if report.batch_export_ids
      trades = Trade.where(:_id.in => report.batch_export_ids.split(',')).order_by(:created.desc)
    else
      trades = report.trades.order_by(:created.desc)
    end

##### 构造报表结构

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1[0, 0] = "订单列表"
    odd_format = Spreadsheet::Format.new  :pattern_bg_color => "white", :color => "black", :pattern_fg_color => "white", :pattern => 1
    even_format = Spreadsheet::Format.new :pattern_bg_color => "gray", :color => "white", :pattern_fg_color => "gray", :pattern => 1
    title_format = Spreadsheet::Format.new :weight => :bold, :size => 18
    bold = Spreadsheet::Format.new(:weight => :bold)

    @row_number = 1

    insert_row = Proc.new{ |trade_index, sheet, body|
      @row_number += 1
      sheet.row(@row_number).concat(body)
      if trade_index.even?
        sheet.row(@row_number).default_format = even_format
      else
        sheet.row(@row_number).default_format = odd_format
      end
    }

##### 插入报表表头

    header = [
    ## 订单信息
    
      "订单来源",
      "订单编号",
      "当前状态",
      "下单时间",
      "付款时间",
      "分派时间",
      "发货时间",
      "支付宝到帐时间",
      "买家地址-省",
      "买家地址-市",
      "买家地址-区",
      "买家地址",
      "发货仓库",
      "买家姓名",
      "买家旺旺",
      "买家手机",
      "买家座机",
      "订单总金额",
      "vip优惠",
      "店铺优惠券",
      "店铺折扣",
      "其他优惠金额",            # 除可读到优惠以外第三方造成的优惠
      "运费",
      "订单实付金额",
      "多退金额",
      "少补金额",
      "买家留言",
      "客服备注",
      "赠品备注",
      "发票信息",
      "物流商",
      "物流单号",
      "打印批次号",
      "打印流水号",

    ## 子订单信息
      "淘宝商品名",
      "淘宝商品编码",
      "淘宝商品单价",
      "淘宝商品实付金额",
      "淘宝商品优惠金额",
      "淘宝商品数量",
      "子订单优惠金额",          # 除“淘宝商品优惠金额”外的其他优惠的总和
      "子订单实付金额",
      "淘宝商品客服备注",
      "淘宝商品属性（淘宝SKU）",
      "子订单退款状态",
      "子订单买家评价结果",
      "子订单买家评价内容",
      "子订单买家评价时间",

    ## 子订单对应本地商品的SKU信息
      "本地商品名称",
      "本地商品编码",
      "本地商品SKU",
      "本地商品数量",
      "本地商品属性备注"
    ]

    sheet1.row(1).concat(header)

##### 报表内容

    trades.each_with_index do |trade, trade_index|

      ## 订单信息

      body = [
        trade.type_text,                                         # 订单来源
        trade.tid,                                               # 订单编号
        trade.taobao_status_memo,                                # 当前状态
        trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S"),        # 下单时间
        trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S"),       # 付款时间
        trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S"),  # 分派时间
        trade.delivered_at.try(:strftime,"%Y-%m-%d %H:%M:%S"),   # 发货时间
        trade.end_time.try(:strftime,"%Y-%m-%d %H:%M:%S"),       # 支付宝到帐时间
        trade.receiver_state,                                    # 买家地址-省
        trade.receiver_city,                                     # 买家地址-市
        trade.receiver_district,                                 # 买家地址-区
        trade.receiver_address,                                  # 买家地址
        trade.seller_name,                                       # 发货仓库
        trade.receiver_name,                                     # 买家姓名
        trade.buyer_nick,                                        # 买家旺旺
        trade.receiver_mobile,                                   # 买家手机
        trade.receiver_phone,                                    # 买家座机
        trade.total_fee,                                         # 订单总金额
        trade.vip_discount,                                      # VIP优惠
        trade.shop_bonus,                                        # 店铺优惠券
        trade.shop_discount,                                     # 店铺折扣
        trade.other_discount,                                    # 其他优惠金额
        trade.post_fee,                                          # 运费
        trade.payment,                                           # 订单实付金额
        -trade.return_ref.try(:ref_payment).to_f,                # 多退金额
        trade.add_ref.try(:ref_payment),                         # 少补金额
        trade.buyer_message,                                     # 买家留言
        trade.cs_memo,                                           # 客服备注
        trade.gift_memo,                                         # 赠品备注
        trade.invoice_name,                                      # 发票信息
        trade.logistic_name,                                     # 物流商
        trade.logistic_waybill,                                  # 物流单号
        trade.deliver_bills.last.try(:batch_num),                # 打印批次号
        trade.deliver_bills.last.try(:serial_num)                # 打印流水号
      ]

      trade_fields_count = body.count

      trade.orders.each_with_index do |order, order_index|

        order_index.zero? ? body = body : body = Array.new(trade_fields_count)

        ## 子订单信息

        body += [
          order.title,                                           # 淘宝商品名
          order.outer_iid,                                       # 淘宝商品编码
          order.price,                                           # 淘宝商品单价
          order.order_price,                                     # 淘宝商品实付金额
          order.product_discount_fee,                            # 淘宝商品优惠金额
          order.num,                                             # 淘宝商品数量
          order.other_discount_fee,                              # 子订单优惠金额
          order.order_payment,                                   # 子订单实付金额
          order.cs_memo,                                         # 淘宝商品客服备注
          order.sku_properties,                                  # 淘宝商品属性（淘宝SKU）
          order.refund_status_text,                              # 子订单退款状态
          order.rate_info.try(:result),                          # 子订单买家评价结果
          order.rate_info.try(:content),                         # 子订单买家评价内容
          order.rate_info.try(:created),                         # 子订单买家评价时间
        ]

        order_field_count = body.count

        if order.skus_info_with_offline_refund.count > 0
          order.skus_info_with_offline_refund.each_with_index do |sku_info, sku_info_index|
            sku_info_index.zero? ? body = body : body = Array.new(order_field_count)

            ## 子订单对应本地商品的SKU信息

            body += [
              sku_info[:name],                                       # 本地商品名称
              sku_info[:outer_id],                                   # 本地商品编码
              sku_info[:sku_properties],                             # 本地商品SKU
              sku_info[:number],                                     # 本地商品数量
              sku_info[:property_memos_text].join("\n")              # 本地商品属性备注
            ]

            insert_row.call(trade_index, sheet1, body)
          end
        else
          insert_row.call(trade_index, sheet1, body)
        end
      end
    end

######报表表头对应字段
    sheet_name = ['type', 'tid', 'status', 'created_time', 'pay_time', 'dispatched_at', 
                  'delivered_at', 'end_time', 'receiver_state', 'receiver_city', 'receiver_district', 
                  'receiver_address', 'seller_name', 'receiver_name', 'buyer_nick', 'receiver_mobile', 'receiver_phone',
                  'total_fee', 'vip_discount', 'shop_discount', 'shop_bonus', 'other_discount', 'post_fee',
                  'payment', 'more_refund', 'less_patch', 'buyer_message', 'cs_memo', 'gift_memo', 
                  'invoice_name', 'logistic_name', 'logistic_waybill', 'batch_num', 'serial_num',
                  'title', 'item_outer_id', 'taobao_price', 'taobao_real_price', 'taobao_discount', 'num',
                  'order_discount', 'order_real_price', 'property_memos_text', 'sku_properties',
                  'order_refund_status_text', 'order_rate_info_result', 'order_rate_info_content', 'order_rate_info_create',
                  'native_name', 'native_outer_id', 'native_sku_properties', 'native_number', 'native_property_memos_text']
    sheet_name.each_with_index do |value, index|
      if user 
        sheet1.column(index).hidden = true unless user.roles.first.permissions[:export_form].include?(value)
      end
    end

##### 导出报表

    file = "#{Rails.root}/data/#{id}.xls"
    book.write file
    report.update_attributes!(performed_at: Time.now)

  end
end

