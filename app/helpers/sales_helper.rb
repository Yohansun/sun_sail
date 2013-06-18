# -*- encoding : utf-8 -*-
module SalesHelper
  def generate_sale_chart_data(start_at, end_at)
    c_map = %Q{
      function() {
        emit(this.created.toString().slice(4,20).concat("0:00"), {created_fee: this.payment});
      }
    }

    p_map = %Q{
      function() {
        if(this.pay_time != null){
          emit(this.pay_time.toString().slice(4,20).concat("0:00"), {paid_fee: this.payment});
        }
      }
    }

    week_c_map = %Q{
      function() {
        emit(this.created.toString().slice(4,17).concat("0:00:00"), {created_fee: this.payment});
      }
    }

    week_p_map = %Q{
      function() {
        if(this.pay_time != null){
          emit(this.pay_time.toString().slice(4,17).concat("0:00:00"), {paid_fee: this.payment});
        }
      }
    }

    month_c_map = %Q{
      function() {
        emit(this.created.toString().slice(4,16).concat("00:00:00"), {created_fee: this.payment});
      }
    }

    month_p_map = %Q{
      function() {
        if(this.pay_time != null){
          emit(this.pay_time.toString().slice(4,16).concat("00:00:00"), {paid_fee: this.payment});
        }
      }
    }

    year_c_map = %Q{
      function() {
        if(this.created.toString().slice(8,9) == 3){
          emit(this.created.toString().slice(4,8).concat("01").concat(Date().toString().slice(10,16)), {created_fee: this.payment});
        } else {
          emit(this.created.toString().slice(4,9).concat("1").concat(Date().toString().slice(10,16)), {created_fee: this.payment});
        }
      }
    }

    year_p_map = %Q{
      function() {
        if(this.pay_time != null){
          if(this.created.toString().slice(8,9) == 3){
            emit(this.pay_time.toString().slice(4,8).concat("01").concat(Date().toString().slice(10,16)), {paid_fee: this.payment});
          } else{
            emit(this.pay_time.toString().slice(4,9).concat("1").concat(Date().toString().slice(10,16)), {paid_fee: this.payment});
          }
        }
      }
    }

    c_reduce = %Q{
      function(key, values) {
        var result = {created_fee: 0};
        values.forEach(function(value) {
          result.created_fee += value.created_fee;
        });
        return result;
      }
    }

    p_reduce = %Q{
      function(key, values) {
        var result = {paid_fee: 0};
        values.forEach(function(value) {
          result.paid_fee += value.paid_fee;
        });
        return result;
      }
    }

    created_trades = TaobaoTrade.where(account_id: current_account.id).between(created: (start_at.to_time - 8.hours)..(end_at.to_time - 8.hours))
    paid_trades = TaobaoTrade.where(account_id: current_account.id).between(pay_time: (start_at.to_time - 8.hours)..(end_at.to_time - 8.hours))

    #计算总金额
    amount_all = created_trades.try(:sum, :payment) || 0
    amount_paid = paid_trades.try(:sum, :payment) || 0

    if end_at.to_i - start_at.to_i < 3.days.to_i
      created_map_reduce = created_trades.map_reduce(c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(p_map, p_reduce).out(inline: true)
    elsif end_at.to_i - start_at.to_i >= 3.days.to_i && end_at.to_i - start_at.to_i < 1.month.to_i
      created_map_reduce = created_trades.map_reduce(week_c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(week_p_map, p_reduce).out(inline: true)
    elsif end_at.to_i - start_at.to_i >= 1.month.to_i && end_at.to_i - start_at.to_i < 3.months.to_i
      created_map_reduce = created_trades.map_reduce(month_c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(month_p_map, p_reduce).out(inline: true)
    elsif end_at.to_i - start_at.to_i >= 3.months.to_i
      created_map_reduce = created_trades.map_reduce(year_c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(year_p_map, p_reduce).out(inline: true)
    end

    #生成图表节点
    enum_paid = paid_map_reduce.sort{|x,y| x["_id"].to_time.to_i <=> y["_id"].to_time.to_i}.to_enum
    enum_created = created_map_reduce.sort{|x,y| x["_id"].to_time.to_i <=> y["_id"].to_time.to_i}.to_enum
    final_hash = {}
    begin
      current_paid = enum_paid.next
      current_created = enum_created.next
      while(1)
        if current_created["_id"] == current_paid["_id"]
          final_hash[current_created["_id"].to_time] = current_created["value"].merge(current_paid["value"])
          current_paid = enum_paid.next
          current_created = enum_created.next
        elsif current_created["_id"].to_time.to_i > current_paid["_id"].to_time.to_i
          while(current_created["_id"].to_time.to_i > current_paid["_id"].to_time.to_i)
            final_hash[current_paid["_id"].to_time] = current_paid["value"].merge("created_fee" => 0.0)
            current_paid = enum_paid.next
          end
        else
          while(current_created["_id"].to_time.to_i < current_paid["_id"].to_time.to_i)
            final_hash[current_created["_id"].to_time] = current_created["value"].merge("paid_fee" => 0.0)
            current_created = enum_created.next
          end
        end
      end
      rescue StopIteration
    end
    begin
      while(1)
        current_created = enum_created.next
        final_hash[current_created["_id"].to_time] = current_created["value"].merge("paid_fee" => "0")
      end
      rescue StopIteration
    end
    begin
      while(1)
        current_paid = enum_paid.next
        final_hash[current_paid["_id"].to_time] = current_paid["value"].merge("created_fee" => "0")
      end
      rescue StopIteration
    end
    [amount_all,amount_paid,final_hash]
  end

  def product_data(trades, old_trades)

    ##对数据map_reduce
    map = %Q{
      function() {
      for(var i in this.taobao_orders) {
        if(this.taobao_orders[i].num_iid != null){
          emit(this.taobao_orders[i].num_iid, {total_fee: this.taobao_orders[i].total_fee, num: this.taobao_orders[i].num });
        }
      }
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {total_fee: 0, num: 0};
        values.forEach(function(value) {
          result.total_fee += value.total_fee;
          result.num += value.num;
        });
        return result;
      }
    }
    map_reduce_info = trades.map_reduce(map, reduce).out(inline: true).sort{|a, b| b['value']['num'] <=> a['value']['num']}
    old_map_reduce_info = old_trades.map_reduce(map, reduce).out(inline: true)

    #处理数据
    sold_info = {}
    old_sold_info = {}
    compare_rate = []

    map_reduce_info.each do |info|
      total_money = info["value"]["total_fee"]
      total_num = info["value"]["num"].to_i
      average_money = (total_money/total_num).round(2)
      sold_info[info["_id"]] = [total_money.round(2), total_num, average_money]
    end

    old_map_reduce_info.each do |info|
      old_total_money = info["value"]["total_fee"]
      old_total_num = info["value"]["num"].to_i
      old_average_money = (old_total_money/old_total_num).round(2)
      old_sold_info[info["_id"]] = [old_total_money.round(2), old_total_num, old_average_money]
    end

    sold_info.each do |key, value|
      if old_sold_info[key]
        rate = (value[1].to_f/old_sold_info[key][1]).round(2)
        compare_rate << [value[0], value[1], value[2], rate, key]
      end
    end
    sold_compare = compare_rate.sort{|a, b| b[3] <=> a[3]}

    [sold_info, sold_compare]
  end

  def area_data(start_at, end_at)

    ##对数据map_reduce
    map = %Q{
      function() {
        emit(this.receiver_state, {payment: this.payment, buyer_nick: this.buyer_nick });
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {payment: 0, buyer_nick: []};
        values.forEach(function(value) {
          result.payment += value.payment;
          if(value.buyer_nick != null){
          result.buyer_nick.push(value.buyer_nick);
          }
        });
        return result;
      }
    }

    trades = TaobaoTrade.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])
    map_reduce_info = trades.map_reduce(map, reduce).out(inline: true).sort{|a, b| a['_id'] <=> b['_id']}

    #处理数据
    money_sum = trades.sum(:payment)
    area_info = []
    map_reduce_info.each do |info|
      state = info["_id"]
      money_rate = (info["value"]["payment"]/money_sum*100).round(3)
      buyer_num = info["value"]["buyer_nick"].to_a.flatten.uniq.count
      trade_num = info["value"]["buyer_nick"].to_a.flatten.count
      area_info << [state, money_rate, buyer_num, trade_num]
    end
    area_info = area_info.sort{|a, b| b[1] <=> a[1]}
  end

  def price_data(start_at, end_at)

    ##对数据map_reduce
    map = %Q{
      function() {
      for(var i in this.taobao_orders) {
        if(this.taobao_orders[i].price != null){
          emit(this.taobao_orders[i].price, {num: this.taobao_orders[i].num });
        }
      }
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {num: 0};
        values.forEach(function(value) {
          result.num += value.num;
        });
        return result;
      }
    }

    trades = TaobaoTrade.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])
    map_reduce_info = trades.map_reduce(map, reduce).out(inline: true)

    #处理数据
    price_info = []
    total_num_sum = 0
    map_reduce_info.each do |info|
      total_num_sum += info["value"]["num"].to_i
    end
    price_gap = [0..2, 2.01..5, 5.01..10, 10.01..29, 29.01..80, 80.01..200, 200.01..500, 500.01..1000, 1000.01..1900, 1900.01..4900, 4900.01..6000]
    price_gap2 = [0..2, 2..5, 5..10, 10..29, 29..80, 80..200, 200..500, 500..1000, 1000..1900, 1900..4900, 4900..6000]
    price_gap.each_with_index do |gap, i|
      num_sum = 0
      map_reduce_info.each do |info|
        if (gap).include?(info["_id"])
          num_sum += info["value"]["num"]
        end
      end
      if total_num_sum != 0
        num_rate = ((num_sum.to_f)/total_num_sum*100).round(2)
      else
        num_rate = 0
      end
      price_info << [price_gap2[i], num_sum.to_i, num_rate]
    end
    price_info
  end

  def time_data(start_at, end_at)
    trades = TaobaoTrade.in(status: ["TRADE_FINISHED","FINISHED_L"])
    day_gap = ((end_at - start_at)/86400).to_i
    start_time = start_at
    day_info = []

    sum_money = trades.between(created: start_at..end_at).sum(:payment).to_f
    time_info = []

    #收集一天内24小时数据
    day_gap.times do |k|
      hour_info = {}
      (0..23).each do |i|
        payment_gap = trades.between(created: start_time..(start_time + 1.hour)).sum(:payment).to_f
        sum = trades.between(created: start_time..(start_time + 1.hour)).count.to_i
        hour_info[i] = [payment_gap, sum]
        start_time = start_time + 1.hour
      end
      day_info << hour_info
    end

    #处理24小时数据
    (0..23).each do |hour|
      if hour + 1 < 10
        hour_gap_1 = "0" + hour.to_s
        hour_gap_2 = "0" + (hour + 1).to_s
      elsif hour + 1 == 10
        hour_gap_1 = "09"
        hour_gap_2 = "10"
      else
        hour_gap_1 = hour.to_s
        hour_gap_2 = (hour + 1).to_s
      end

      hour_payment = 0
      hour_sum = 0
      day_gap.times do |day|
        hour_payment += day_info[day][hour][0]
        hour_sum += day_info[day][hour][1]
      end
      if sum_money != 0
        hour_payment_rate = (hour_payment/sum_money*100).round(2)
      else
        hour_payment_rate = 0
      end
      hour_daily_payment = (hour_sum.to_f/day_gap).round(1)

      time_info << [hour_gap_1, hour_gap_2, hour_payment_rate, hour_sum, hour_daily_payment]
    end
    time_info
  end

  def frequency_data(start_at, end_at)
    map = %Q{
      function() {
          emit(this.buyer_nick, {num: 1 });
      }
    }

    reduce = %Q{
       function(key, values) {
         var result = {num: 0};
         values.forEach(function(value) {
            result.num += value.num;
         });
         return result;
       }
     }

     trades = TaobaoTrade.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])
     frequency = trades.map_reduce(map, reduce).out(inline: true)
     purchase_num = Array.new(15,0)
     frequency_info = []
     total_num = 0
     frequency.each do |fre|
       total_num += fre["value"]["num"].to_i
       (0..13).each do |i|
         if fre["value"]["num"].to_i == i+1
           purchase_num[i] += 1
         end
       end
       if fre["value"]["num"].to_i>=15
         purchase_num[14] += 1
       end
     end
     purchase_num.each do |p|
       total_num != 0 ? purchase_data = (p/total_num.to_f*100).round(2) : purchase_data = 0
       frequency_info << [p , purchase_data]
     end
     frequency_info
  end

  def univalent_data(start_at, end_at)
    map = %Q{
      function() {
          emit(this.buyer_nick, {payment: this.payment , num: 1 });
      }
    }

    reduce = %Q{
       function(key, values) {
         var result = {payment:0 , num: 0};
         values.forEach(function(value) {
            result.num += value.num;
            result.payment += value.payment
         });
         return result;
       }
     }

     trades = TaobaoTrade.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])
     univalent = trades.map_reduce(map, reduce).out(inline: true)
     univalent_info = []
     total_num = 0
     payment_money = 0
     average_money = []
     money_gap = money_gap = [0..2, 2.01..5, 5.01..10, 10.01..29, 29.01..80, 80.01..200, 200.01..500, 500.01..1000, 1000.01..1900, 1900.01..4900, 4900.01..6000]
     money_gap2 = [0..2, 2..5, 5..10, 10..29, 29..80, 80..200, 200..500, 500..1000, 1000..1900, 1900..4900, 4900..6000]
     person_num = Array.new(11 , 0)
     total_person_num = 0
     money_gap.each_with_index do |gap, i|
       univalent.each do |fre|
         total_num = fre["value"]["num"].to_i
         payment_money = fre["value"]["payment"].to_f
         average_money = payment_money/total_num
         if (gap).include?(average_money)
           person_num[i] += 1
         end
       end
       total_person_num += person_num[i]
     end
     person_num.each_with_index do |p, i|
       total_person_num != 0 ? univalent_data = (p/total_person_num.to_f*100).round(2) : univalent_data = 0
       univalent_info << [money_gap2[i], p , univalent_data]
     end
     univalent_info
  end

end