#encoding: utf-8
class Reports < ActionMailer::Base
  # 默认发送昨天的
  # Reports.trades_consolidate_with_day(account_key,:date => '2012-01-01')
  # account_key "brands"
  # ##
  # *options*
  # :date '2013-01-01 00:00:00' , '2013-01-01', Time.now
  # :to   recipient email address
  # :bcc  [bcc]
  # :tag  default is '电商数据'
  def trades_consolidate_with_day(*args)
    options = args.extract_options!
    options[:date] ||= Time.now.yesterday
    options[:tag] ||= '电商数据'
    account_key = args.shift

    @account = Account.find_by_key(account_key)
    raise "没有找到#{account_key}该账户" if @account.nil?
    @trades = Trade.time_range_with_account(@account.id,options[:date])

    options[:from] = @account.settings.email_notifier_from

    @paid_trades = @trades.where(:pay_time.ne => nil)

    options[:subject] = subject(@account.name,options[:tag],options[:date].strftime("%Y-%m-%d"))

    hash = options.slice(:to,:bcc,:subject,:from).keep_if {|k,v| !v.nil?}

    raise ArgumentError,"Recipient mail can't be blank! " if options[:to].blank?
    
    mail(hash)
  end


  private
  # subject '白兰氏','异常核查报告','2013-07-09 10:10:24'
  # => "Magic白兰氏 异常核查报告 2013-07-09 10:10:24"
  def subject(*extra)
    subject = "Magic"
    subject << extra.join(" ")
  end
end
