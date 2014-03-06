# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
root_path = File.expand_path('.')
set :output, File.join(root_path,'log/cron_log.log')
DEFAULT_FROM = "magic-notifer@networking.io"
Accounts = {
  :brands => [:brands,{
    :to => %w(asher_qian@allyes.com
              lynn_lin@allyes.com
              zhao_wang@allyes.com
              nancy_wu@allyes.com
              fei_wang@allyes.com
              yang_wang@allyes.com),
    :bcc  => %w(magic_sh@doorder.com errors@networking.io),
    :from => "#{DEFAULT_FROM}"
    }]
}


STORY_1204 = %w(
errors@networking.io
wynn@doorder.com
michelle@doorder.com
clover@doorder.com
pumpkin@doorder.com
steven@doorder.com
ophelia@doorder.com
mark@doorder.com
)

every :day, :at => '10:00am' do
  runner "Reports.trades_consolidate_with_day(*#{Accounts[:brands]}).deliver!"
end

def start_time
  "Time.now.yesterday.beginning_of_day"
end

def end_time
  "Time.now.yesterday.end_of_day"
end

every :day, :at => '9:00am' do
  runner "TradeChecker.new(start_time: #{start_time},end_time: #{end_time},:to => #{STORY_1204},:from => \"#{DEFAULT_FROM}\").deliver"
end

every :day, :at => '9:00pm' do
  runner "TradeChecker.new(start_time: #{start_time},end_time: #{end_time},:to => #{STORY_1204},:from => \"#{DEFAULT_FROM}\").deliver"
end

every :day, :at => '2:00pm' do
  runner "Notifier.system_sms_out_of_usage_notifications.deliver"
end

# TODO：可以优化为将队列执行请求直接插入redis数据库，以节省内存
every 5.minutes do
  runner "MergeableTradeMarker.new.perform()"
end

every 5.minutes do
  runner "TradeSource.where(trade_type: 'Taobao',jushita_sync: true).each {|u| TaobaoPullerBuilder.perform_async(u.id); TaobaoTradePuller.update(nil, nil, u.id)}"
end

every 30.minutes do
  runner "BiaoganPusher.check"
end

every 3.hours do
  runner "UnusualTradesNotifier.new.perform()"
end

every :day, :at => '00:00am' do
  runner "start_time = Time.now.yesterday.beginning_of_day;end_time = Time.now.yesterday.end_of_day; AlipayRevenuePuller.create(start_time,end_time,201)"
end

every :month, :at => '02:00am' do
  runner "trade_source_id = 201; FinanceCalculate.new.perform(trade_source_id)"
end
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
