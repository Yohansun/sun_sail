#encoding: utf-8
# STORY #892 仓库管理 单仓库修改成多仓库形式 更新经销商的仓库数据(seller_id)
task :sync_seller_with_stock_bill => :environment do
  STDOUT.print "确保数据更新时数据没有任何操作,否则会覆盖数据. 确认进行操作?(Y/N)"
  input = STDIN.gets.chomp
  abort("已退出执行") if input =~ /n|no/i
  failure_ids = []
  StockBill.each do |stock_bill|
    trade = Trade.find_by(:tid => stock_bill.tid) rescue nil
    format = if trade.nil?
      failure_ids << stock_bill.tid
      "\e[00;31m%s"
    else
      stock_bill.save(validate: false) if stock_bill.seller_id != trade.seller_id && !stock_bill.update_attribute(:seller_id,trade.seller_id)
      "\e[00;32m%s"
    end
    $stdout.print format % "*"
    $stdout.flush
  end
  puts "\n" + "\e[00;31m%s" % "[Not found!] Trade#tids => #{failure_ids.to_s}"
end