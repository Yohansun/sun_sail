module SalesHelper
	def sold_count(trades)
    map = %Q{
      function() {
      for(var i in this.taobao_orders) {
        emit(this.taobao_orders[i].outer_iid, {total_fee: this.taobao_orders[i].total_fee, num: this.taobao_orders[i].num });
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
    
    map_reduce_info = trades.map_reduce(map, reduce).out(inline: true)
    sold_info = {}

    map_reduce_info.each do |info| 
	    total_money = info["value"]["total_fee"]
	    total_num = info["value"]["num"].to_i
	    average_money = (total_money/total_num).round(2)
		  sold_info[info["_id"]] = [total_money.round(2), total_num, average_money]
    end
    sold_info
  end
end