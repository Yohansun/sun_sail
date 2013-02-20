# -*- encoding : utf-8 -*-
class DailyOrdersNotifier < ActionMailer::Base
  default :from => TradeSetting.email_notifier_from  

  def check_status_result(start_time, end_time, lost_orders, wrong_orders, bad_status_orders, hidden_orders)
    reciever = TradeSetting.check_status_result_reciever
    @start_time = start_time
    @end_time = end_time
    @lost_orders = lost_orders
    @wrong_orders = wrong_orders
    @bad_status_orders = bad_status_orders
    @hidden_orders = hidden_orders
    mail(:to => reciever, :subject => "#{TradeSetting.site_title_basic} 异常核查报告 #{Time.now}")
  end

  def yesterday
    reciever = TradeSetting.email_dailyorders_yesterday_reciever
    cc = TradeSetting.email_dailyorders_yesterday_cc
    bcc = TradeSetting.email_dailyorders_yesterday_bcc

    yesterday = 1.days.ago
    yesterday_begin = yesterday.beginning_of_day
    yesterday_end =  yesterday.end_of_day
    
    @taobao_trades = TaobaoTrade.between(:created => yesterday_begin..yesterday_end).count
    @taobao_paid_trades = TaobaoTrade.between(pay_time: yesterday_begin..yesterday_end).count
    @taobao_paid = TaobaoTrade.between(pay_time: yesterday_begin..yesterday_end).inject(0.0) { |sum, trade| sum + trade.payment }

    if TradeSetting.company == "nippon"
      @taobao_purchase_orders =  TaobaoPurchaseOrder.between(created: yesterday_begin..yesterday_end).count
      @taobao_purchase_paid_orders =  TaobaoPurchaseOrder.between(pay_time: yesterday_begin..yesterday_end)
      @taobao_purchase_paid = TradeDecorator.decorate(@taobao_purchase_paid_orders).inject(0.0) { |sum, trade| sum + trade.total_fee.to_f }
    end

    email_subject = "#{yesterday.strftime("%Y年%m月%d日")} #{TradeSetting.site_title_basic} 电商数据"

    mail(:to => reciever, :cc => cc, :bcc => bcc, :subject => email_subject)
  end
end
