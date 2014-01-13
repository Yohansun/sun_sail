# -*- encoding : utf-8 -*-
class DailyOrdersNotifier < ActionMailer::Base
  # trade_checker = TradeChecker.new
  # trade_checker.check
  # DailyOrdersNotifier.check_status_result(trade_checker,:to => '...',:bcc => '...').deliver!
   def check_status_result(*args)
     options = args.extract_options!
     options[:tag] ||= '异常核查报告'
     @trade_checker = args.shift

    options[:from] ||= "exception-checker@networking.io"

    options[:subject] = subject(nil,options[:tag],Time.now.strftime("%Y-%m-%d %H:%M:%S"))

    options[:to] ||= "errors@networking.io"

    hash = options.slice(:to,:bcc,:cc,:subject,:from).keep_if {|k,v| !v.nil?}

    raise ArgumentError,"Recipient mail can't be blank! " if options[:to].blank?

    mail(hash)
  end

  def yesterday(account_id)
    @account = Account.find(account_id)

    yesterday = 1.days.ago
    yesterday_begin,yesterday_end = yesterday.beginning_of_day,yesterday.end_of_day
    con = Trade.where({account_id: account_id}).between(:created => yesterday_begin..yesterday_end).between(pay_time: yesterday_begin..yesterday_end)
    created_con,paid_con = con.except("pay_time"), con.except("created")
    @taobao_trades = TaobaoTrade.where(paid_con)
    @taobao_paid_trades = TaobaoTrade.where(created_con)

    if @account.key == "nippon"
      @taobao_purchase_orders =  TaobaoPurchaseOrder.where(created_con)
      @taobao_purchase_paid_orders =  TaobaoPurchaseOrder.where(paid_con)
      @taobao_purchase_paid_price = TradeDecorator.decorate(@taobao_purchase_paid_orders).inject(0.0) { |sum, trade| sum + trade.total_fee.to_f }
    end

    mail({
      :from     => @account.settings.email_notifier_from, 
      :to       => @account.settings.email_dailyorders_yesterday_reciever, 
      :cc       => @account.settings.email_dailyorders_yesterday_cc, 
      :bcc      => @account.settings.email_dailyorders_yesterday_bcc, 
      :subject  => "#{I18n.l(yesterday,format: :short)} #{@account.settings.site_title_basic} 电商数据"
    })
  end
  private
  # subject '白兰氏','异常核查报告','2013-07-09 10:10:24'
  # => "Magic白兰氏 异常核查报告 2013-07-09 10:10:24"
  def subject(*extra)
    subject = "Magic"
    subject << extra.join(" ")
  end
end