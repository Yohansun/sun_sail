# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
root_path = File.expand_path('.')
set :output, File.join(root_path,'log/cron_log.log')
Accounts = {
  :brands => [:brands,{
    # :to => %w(asher_qian@allyes.com
    # lynn_lin@allyes.com
    # zhao_wang@allyes.com
    # nancy_wu@allyes.com
    # fei_wang@allyes.com
    # yang_wang@allyes.com),
    :to => %w(
    pumpkin@doorder.com
    steven@doorder.com
    xiaoliang@networking.io
    zhoubin@networking.io
    )
  # :bcc => %w(errors@networking.io
  # wynn@doorder.com
  # michelle@doorder.com
  # clover@doorder.com
  # pumpkin@doorder.com)
  }]
}
every :day, :at => '2:00am', :roles => [:app] do
  runner "Reports.trades_consolidate_with_day(*#{Accounts[:brands]}).deliver!"
end

every :day, :at => '9:00am', :roles => [:app] do
  runner "TradeChecker.new(:brands).invoke"
end

every :day, :at => '9:00pm', :roles => [:app] do
  runner "TradeChecker.new(:brands).invoke"
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
