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
    
    yesterday = Time.now - 1.day
    year = yesterday.year
    month = yesterday.month
    day = yesterday.day

    yesterday_begin = Time.local(year,month,day,0,0,0).utc
    yesterday_end =  Time.local(year,month,day,23,59,59).utc
    
    if TradeSetting.company == "dulux"
      @taobao_trades = TaobaoTrade.where(:created => yesterday_begin..yesterday_end)
      @taobao_paid_trades = TaobaoTrade.where(:pay_time => yesterday_begin..yesterday_end)
      @taobao_paid = TradeDecorator.decorate(@taobao_paid_trades).inject(0) { |sum, trade| sum + trade.total_fee.to_f }
      email_subject = "#{year}年#{month}月#{day}日#{TradeSetting.site_title_basic} 淘宝电商数据"    
    else
      @jingdong_trades = JingdongTrade.where(:created => yesterday_begin..yesterday_end)
      @jingdong_paid_trades = JingdongTrade.where(:created => yesterday_begin..yesterday_end)
      @jingdong_paid = TradeDecorator.decorate(@jingdong_paid_trades).inject(0) { |sum, trade| sum + trade.total_fee.to_f }
      
      @taobao_purchase_orders =  TaobaoPurchaseOrder.where(:created => yesterday_begin..yesterday_end)
      @taobao_purchase_paid_orders =  TaobaoPurchaseOrder.where(:pay_time => yesterday_begin..yesterday_end)
      @taobao_purchase_paid = TradeDecorator.decorate(@taobao_purchase_paid_orders).inject(0) { |sum, trade| sum + trade.total_fee.to_f }
      email_subject = "#{year}年#{month}月#{day}日(京东,分销)电商数据"    
    end
    mail(:to => reciever, :cc => cc, :bcc => bcc, :subject => email_subject)
  end
end
