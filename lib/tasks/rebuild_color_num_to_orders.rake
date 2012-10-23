# -*- encoding:utf-8 -*-

desc "更新调色数据结构"
task :rebuild_color_num_to_orders => :environment do
  TaobaoTrade.where.each do |trade|
    puts "work with #{trade.tid}"
    trade.orders.each do |order|
      tmp = []
      order.color_num.each do |color|
        if color.class == Array
          tmp << color
        else
          tmp << [color]
        end
      end

      order.color_num = tmp
    end

    trade.save
  end
end
