# -*- encoding:utf-8 -*-
require "csv"

desc "赠品留言"
task :free_goods_memo => :environment do
  DATA = [
    {
      file: '1-100.csv',
      memo: " 1～100单，送价值499元伊莱克斯光波炉一台"
    },
    {
      file: '101-399.csv',
      memo: " 101～399单，送价值299元飞利浦搅拌机一台"
    },
    {
      file: '400-1000.csv',
      memo: " 400～1000单，送价值199元的多乐士辅料套装一套（套装含：2把通用滚筒，2把4寸毛刷，3卷砂纸）"
    },
    {
      file: '1000.csv',
      memo: " 满1000单后，每百单获得多乐士厨房7件套一套。"
    }
  ]

  puts "更新赠品备注"
  DATA.each do |item|
    puts "work with #{item[:file]}"
    CSV.foreach("#{Rails.root}/lib/data_source/" + item[:file]) do |row|
      update_gift_memo(row[0], item[:memo])
    end
  end


  puts "更新整单备注"
  TaobaoTrade.where({"taobao_orders" => {"$elemMatch" => {outer_iid: 'ICI0052'}}}).each do |trade|
    trade.cs_memo ||= ''
    trade.cs_memo += " 送一个滚筒"
    puts "#{trade.tid} save fail" unless trade.save
  end
end

def update_gift_memo(tid, memo)
  trade = Trade.where(tid: tid).first

  unless trade
    puts "#{tid} not found"
  else
    trade.gift_memo ||= ''
    trade.gift_memo += memo
    puts "#{tid} save fail" unless trade.save
  end
end
