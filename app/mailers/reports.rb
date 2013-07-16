#encoding: utf-8
class Reports < ActionMailer::Base
  # 默认发送昨天的
  # Reports.trades_consolidate_with_day(account_ids,:date => '2012-01-01')
  # account_ids default all Account.disti
  # ##
  # *options*
  # :date '2013-01-01 00:00:00' , '2013-01-01', Time.now
  # :to   recipient email address
  # :bcc  bcc
  # :tag  '电商数据'
  def trades_consolidate_with_day(*args)
    options = args.extract_options!
    options[:date] ||= Time.now.yesterday
    options[:tag] ||= '电商数据'
    account_id = args.shift
    
    @account = Account.find(account_id)
    @trades = Trade.time_range_with_account(account_id,options[:date])
    @paid_trades = @trades.where(:pay_time.ne => nil)
    @trade_count,@paid_trades_count,@payment = [@trades.count,@paid_trades.count,@paid_trades.sum(:payment)]
    
    options[:subject] = subject(@account.name,options[:tag],options[:date].strftime("%Y-%m-%d"))
    hash = options.slice(:to,:bcc,:subject).keep_if {|k,v| !v.nil?}
    
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
