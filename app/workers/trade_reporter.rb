# -*- encoding : utf-8 -*-
class TradeReporter
  include Sidekiq::Worker
  include BaseHelper
  sidekiq_options :queue => :reporter

  def perform(id)
    report = TradeReport.find(id)
    current_user = User.find(report.user_id)
    hash = report.conditions
    hash = recursive_symbolize_keys! hash
    trades = Trade.filter(current_user, hash)
    trades = TradeDecorator.decorate(trades.order_by("created", "DESC"))
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1[0, 0] = "订单列表"

    yellow_format = Spreadsheet::Format.new :pattern_bg_color => "yellow", :color => "black", :pattern_fg_color => "yellow", :pattern => 1
    blue_format = Spreadsheet::Format.new :pattern_bg_color => "blue", :color => "white", :pattern_fg_color => "blue", :pattern => 1
    title_format = Spreadsheet::Format.new :color => "blue", :weight => :bold, :size => 18
    bold = Spreadsheet::Format.new(:weight => :bold)

    row_number = 2

    if TradeSetting.company == "dulux"
      if current_user.has_role?(:seller) || current_user.has_role?(:logistic)
        sheet1.row(1).concat ["订单号", "下单时间", "付款时间", "分流时间", "订单状态",
                              "送货经销商", "买家地址-省", "买家地址-市", "买家地址-区", "买家地址", "买家姓名", "收货人手机/座机", "商品名", "数量", "运费", "买家旺旺", "客服备注", "需要调色", "色号"]
        trades.each_with_index do |trade, trade_index|
          if trade.splitted?
            OrderDecorator.decorate(trade.orders).each_with_index do |order, i|
              cs_memo = "#{trade.cs_memo} #{order.cs_memo}"
              if order.color_num.present?
                color_num = order.color_num.join(",")
              else
                color_num = ''
              end
              need_color = trade.has_color_info ? '是' : '否'
              sheet1.update_row row_number + i, trade.splitted_tid,
              trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S"),
              trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.status_text, trade.seller_name,
              trade.receiver_state, trade.receiver_city, trade.receiver_district, trade.receiver_address, trade.receiver_name, trade.receiver_mobile_phone, order.title, order.num, trade.post_fee, trade.buyer_nick, cs_memo, need_color, color_num
              if trade_index.even?
                sheet1.row(row_number + i).default_format = yellow_format
              else
                sheet1.row(row_number + i).default_format = blue_format
              end
            end
          else
            OrderDecorator.decorate(trade.orders).each_with_index do |order, i|
              cs_memo = "#{trade.cs_memo} #{order.cs_memo}"
              if order.color_num.present?
                color_num = order.color_num.join(",")
              else
                color_num = ''
              end
              need_color = trade.has_color_info ? '是' : '否'
              sheet1.update_row row_number + i, trade.tid,
              trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S"),
              trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.status_text, trade.seller_name,
              trade.receiver_state, trade.receiver_city, trade.receiver_district, trade.receiver_address, trade.receiver_name, trade.receiver_mobile_phone, order.title, order.num, trade.post_fee, trade.buyer_nick, cs_memo, need_color, color_num
              if trade_index.even?
                sheet1.row(row_number + i).default_format = yellow_format
              else
                sheet1.row(row_number + i).default_format = blue_format
              end
            end
          end
          row_number = row_number + trade.orders.count
        end
      elsif current_user.has_role?(:cs) || current_user.has_role?(:admin)
        sheet1.row(1).concat ["订单号", "下单时间", "付款时间", "分流时间", "订单状态",
                              "送货经销商", "买家地址-省", "买家地址-市", "买家地址-区", "买家地址", "买家姓名", "收货人手机/座机", "商品名", "数量", "商品标价", "实际单价", "卖家优惠", "单品总价", "商品总价（不含运费）", "运费", "订单总金额", "买家旺旺", "客服备注", "需要调色", "色号"]
        trades.each_with_index do |trade,trade_index|
          if trade.splitted?
            OrderDecorator.decorate(trade.orders).each_with_index do |order, i|
              cs_memo = "#{trade.cs_memo} #{order.cs_memo}"
              if order.color_num.present?
                color_num = order.color_num.join(",")
              else
                color_num = ''
              end
              need_color = trade.has_color_info ? '是' : '否'
              sheet1.update_row row_number + i, trade.splitted_tid,
              trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S"),
              trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.status_text, trade.seller_name,
              trade.receiver_state, trade.receiver_city, trade.receiver_district, trade.receiver_address, trade.receiver_name, trade.receiver_mobile_phone, order.title, order.num, order.auction_price, order.price, order.discount_fee, order.total_fee, trade.sum_fee, trade.post_fee, trade.total_fee, trade.buyer_nick, cs_memo, need_color, color_num
              if trade_index.even?
                sheet1.row(row_number + i).default_format = yellow_format
              else
                sheet1.row(row_number + i).default_format = blue_format
              end
            end
          else
            OrderDecorator.decorate(trade.orders).each_with_index do |order, i|
              cs_memo = "#{trade.cs_memo} #{order.cs_memo}"
              if order.color_num.present?
                color_num = order.color_num.join(",")
              else
                color_num = ''
              end
              need_color = trade.has_color_info ? '是' : '否'
              sheet1.update_row row_number + i, trade.tid,
              trade.created.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.pay_time.try(:strftime,"%Y-%m-%d %H:%M:%S"),
              trade.dispatched_at.try(:strftime,"%Y-%m-%d %H:%M:%S"), trade.status_text, trade.seller_name,
              trade.receiver_state, trade.receiver_city, trade.receiver_district, trade.receiver_address, trade.receiver_name, trade.receiver_mobile_phone, order.title, order.num, order.auction_price, order.price, order.discount_fee, order.total_fee, trade.sum_fee, trade.post_fee, trade.total_fee, trade.buyer_nick, cs_memo, need_color, color_num
              if trade_index.even?
                sheet1.row(row_number + i).default_format = yellow_format
              else
                sheet1.row(row_number + i).default_format = blue_format
              end
            end
          end
          row_number = row_number + trade.orders.count
        end
      end
    end
    book.write "#{Rails.root}/data/#{id}.xls"
    report.update_attributes!(performed_at: Time.now)
  end
end