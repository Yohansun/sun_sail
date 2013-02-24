# -*- encoding : utf-8 -*-
class DailyOrdersNotifier < ActionMailer::Base
 
   def check_status_result(account_id, start_time, end_time, lost_orders, wrong_orders, bad_status_orders, hidden_orders)
    account = Account.find_by_id(account_id)
    from = account.settings.email_notifier_from
    reciever = account.settings.check_status_result_reciever
    @start_time = start_time
    @end_time = end_time
    @lost_orders = lost_orders
    @wrong_orders = wrong_orders
    @bad_status_orders = bad_status_orders
    @hidden_orders = hidden_orders
    mail(:from => from, :to => reciever, :subject => "#{account.settings.site_title_basic} 异常核查报告 #{Time.now}")
  end

  def yesterday(account_id)
    @account = Account.find_by_id(account_id)
    reciever = @account.settings.email_dailyorders_yesterday_reciever
    cc = @account.settings.email_dailyorders_yesterday_cc
    bcc = @account.settings.email_dailyorders_yesterday_bcc
    from = @account.settings.email_notifier_from

    yesterday = 1.days.ago
    yesterday_begin = yesterday.beginning_of_day
    yesterday_end =  yesterday.end_of_day
    
    @taobao_trades = TaobaoTrade.where(account_id: account_id).between(:created => yesterday_begin..yesterday_end).count
    @taobao_paid_trades = TaobaoTrade.where(account_id: account_id).between(pay_time: yesterday_begin..yesterday_end).count
    @taobao_paid = TaobaoTrade.where(account_id: account_id).between(pay_time: yesterday_begin..yesterday_end).inject(0.0) { |sum, trade| sum + trade.payment }

    if @account.key == "nippon"
      @taobao_purchase_orders =  TaobaoPurchaseOrder.where(account_id: account_id).between(created: yesterday_begin..yesterday_end).count
      @taobao_purchase_paid_orders =  TaobaoPurchaseOrder.where(account_id: account_id).between(pay_time: yesterday_begin..yesterday_end)
      @taobao_purchase_paid = TradeDecorator.decorate(@taobao_purchase_paid_orders).inject(0.0) { |sum, trade| sum + trade.total_fee.to_f }
    end

    email_subject = "#{yesterday.strftime("%Y年%m月%d日")} #{@account.settings.site_title_basic} 电商数据"

    mail(:from => from, :to => reciever, :cc => cc, :bcc => bcc, :subject => email_subject)
  end
end
