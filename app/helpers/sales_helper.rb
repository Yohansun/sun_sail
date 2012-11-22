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
end