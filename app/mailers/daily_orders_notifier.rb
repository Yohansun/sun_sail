# -*- encoding : utf-8 -*-
class DailyOrdersNotifier < ActionMailer::Base
  # trade_checker = TradeChecker.new(:brands).taobao_trade_status
  # DailyOrdersNotifier.check_status_result(trade_checker,:to => '...',:bcc => '...').deliver!
   def check_status_result(*args)
     options = args.extract_options!
     options[:tag] ||= '异常核查报告'
     trade_checker = args.shift

    @trade_checkers = [trade_checker]

    #默认发送今天凌晨1点到现在前30分钟的数据
    if trade_checker.end_time.to_date != Date.today
      @trade_checkers << TradeChecker.new(trade_checker.account_key,start_time: Time.now.beginning_of_day,end_time: Time.now - 30.minutes).taobao_trade_status
    end
    account = trade_checker.account
    options[:from] ||= account.settings.email_notifier_from

    options[:subject] = subject(account.name,options[:tag],Time.now.strftime("%Y-%m-%d %H:%M:%S"))

    options[:to] ||= account.settings.check_status_result_reciever

    hash = options.slice(:to,:bcc,:cc,:subject,:from).keep_if {|k,v| !v.nil?}

    raise ArgumentError,"Recipient mail can't be blank! " if options[:to].blank?

    mail(hash)
  end

  def yesterday(account_id)
    @account = Account.find(account_id)
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
  private
  # subject '白兰氏','异常核查报告','2013-07-09 10:10:24'
  # => "Magic白兰氏 异常核查报告 2013-07-09 10:10:24"
  def subject(*extra)
    subject = "Magic"
    subject << extra.join(" ")
  end
end