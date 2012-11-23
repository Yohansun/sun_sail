module SalesHelper
	def product_data(trades, old_trades)

    ##对数据map_reduce
    map = %Q{
      function() {
      for(var i in this.taobao_orders) {
        if(this.taobao_orders[i].outer_iid != null){
          emit(this.taobao_orders[i].outer_iid, {total_fee: this.taobao_orders[i].total_fee, num: this.taobao_orders[i].num });
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

    p [sold_info, sold_compare]
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

    price_info = []
    total_num_sum = 0
    map_reduce_info.each do |info|
      total_num_sum += info["value"]["num"].to_i
    end
    price_gap = [0..2, 2..5, 5..10, 10..29, 29..80, 80..200, 200..500, 500..1000, 1000..1900, 1900..4900, 4900..6000]

    price_gap.each do |gap|
      num_sum = 0
      map_reduce_info.each do |info|
        if (gap).include?(info["_id"])
          num_sum += info["value"]["num"]
        end
      end
      num_rate = ((num_sum.to_f)/total_num_sum*100).round(2)
      price_info << [gap, num_sum, num_rate]
    end
    price_info
  end

end