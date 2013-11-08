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
    }],
    #瑞莱
  :"911573445" => [:"911573445",{
    :to => %w(zhao_wang@allyes.com
              linda_jin@allyes.com
              yao_wu@allyes.com),
    :bcc => %w(magic_sh@doorder.com),
    :from => "#{DEFAULT_FROM}"
    }]
}


STORY_1204 = %w(
errors@networking.io
wynn@doorder.com
michelle@doorder.com
clover@doorder.com
pumpkin@doorder.com
zhoubin@networking.io
wang@networking.io
xiaoliang@networking.io
)

every :day, :at => '10:00am' do
  runner "Reports.trades_consolidate_with_day(*#{Accounts[:brands]}).deliver!"
  runner "Reports.trades_consolidate_with_day(*#{Accounts[:"911573445"]}).deliver!"
end

every :day, :at => '9:00am' do
  runner "TradeChecker.new(:brands,start_time: Time.now.yesterday.beginning_of_day,end_time: Time.now - 30.minutes,:to => #{STORY_1204},:from => \"#{DEFAULT_FROM}\").invoke"
end

every :day, :at => '9:00pm' do
  runner "TradeChecker.new(:brands,:to => #{STORY_1204},:from => \"#{DEFAULT_FROM}\").invoke"
end

every :day, :at => '2:00pm' do
  runner "Notifier.system_sms_out_of_usage_notifications.deliver"
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
