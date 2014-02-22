# -*- encoding : utf-8 -*-
module MagicReport

  ExportTaobaoProductAnalysis = ['export_top_ten_with_category_analysis',
                                 'export_category_comparism_analysis',
                                 'export_product_num_with_seller_analysis']

  def top_ten_with_category_analysis(current_account, start_at, end_at)
    trades = current_account.trades.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])

    ##对数据map_reduce
    map = %Q{
      function() {
      for(var i in this.taobao_orders) {
        if(this.taobao_orders[i].num_iid != null){
          emit(this.taobao_orders[i].num_iid, {price: this.taobao_orders[i].price, num: this.taobao_orders[i].num, outer_iid: this.taobao_orders[i].outer_iid, title: this.taobao_orders[i].title});
        }
      }
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {title: values[0].title, price: values[0].price, num: 0, outer_iid: values[0].outer_iid};
        values.forEach(function(value) {
          result.num += value.num;
        });
        return result;
      }
    }

    map_reduce_info = trades.map_reduce(map, reduce).out(inline: true).sort{|a, b| b['value']['num'] <=> a['value']['num']}
    map_reduce_info = add_cat_name_to_data(map_reduce_info)

    top_ten_with_category_data = []

    map_reduce_info.group_by{|info| info['value']['cat_name']}.each do |key, values|
      values.first(10).each{|value| top_ten_with_category_data << value }
    end

    top_ten_with_category_data

  end

  def category_comparism_analysis(current_account, start_at, end_at)
    trades = current_account.trades.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])

    ##对数据map_reduce
    map = %Q{
      function() {
      for(var i in this.taobao_orders) {
        if(this.taobao_orders[i].num_iid != null){
          emit(this.taobao_orders[i].num_iid, {total_fee: this.taobao_orders[i].price * this.taobao_orders[i].num, num: this.taobao_orders[i].num});
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
    map_reduce_info = add_cat_name_to_data(map_reduce_info)

    category_fee_data, category_num_data = [], []
    sum_num     = map_reduce_info.sum{|info| info['value']['num']}
    sum_fee     = map_reduce_info.sum{|info| info['value']['total_fee']}

    map_reduce_info.group_by{|info| info['value']['cat_name']}.each do |key, values|
      single_category_num = values.sum{|info| info['value']['num']}
      num_percent         = (single_category_num.to_f/sum_num*100).round(2).to_s+"%"
      category_num_data << [key, single_category_num, num_percent]

      single_category_fee = values.sum{|info| info['value']['total_fee']}
      fee_percent         = (single_category_fee.to_f/sum_fee*100).round(2).to_s+"%"
      category_fee_data << [key, single_category_fee, fee_percent]
    end

    category_data = [category_num_data.sort{|a,b| b[1] <=> a[1]}, category_fee_data.sort{|a,b| b[1] <=> a[1]}] || []
  end

  def product_num_with_seller_analysis(current_account, start_at, end_at)
    trades = current_account.trades.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])

    ##对数据map_reduce
    map = %Q{
      function() {
      for(var i in this.taobao_orders) {
        if(this.taobao_orders[i].num_iid != null){
          emit({num_iid: this.taobao_orders[i].num_iid, seller_id: this.seller_id}, {num: this.taobao_orders[i].num, outer_iid: this.taobao_orders[i].outer_iid, title: this.taobao_orders[i].title});
        }
      }
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {title: values[0].title, num: 0, outer_iid: values[0].outer_iid};
        values.forEach(function(value) {
          result.num += value.num;
        });
        return result;
      }
    }

    map_reduce_info = trades.map_reduce(map, reduce).out(inline: true).sort{|a, b| b['value']['num'] <=> a['value']['num']}
    map_reduce_info = add_cat_name_to_data(map_reduce_info)

    product_num_with_seller_data = []
    map_reduce_info.group_by{|info| info['_id']['num_iid']}.each do |key, values|
      product_sum = values.sum{|info| info['value']['num']}
      single_product_data = [
        values[0]['value']['cat_name'],
        values[0]['value']['title'],
        values[0]['value']['outer_iid'],
        product_sum
      ]
      current_account.sellers.each do |seller|
        single_product_data << (values.find{|v| v['_id']['seller_id'] == seller.id}['value']['num'] rescue '')
      end

      product_num_with_seller_data << single_product_data
    end

    product_num_with_seller_data
  end

  def add_cat_name_to_data(map_reduce_info)
    map_reduce_info.each do |info|
      info['value']['cat_name'] = TaobaoProduct.find_by_num_iid(info['_id']['num_iid'] || info['_id']).try(:cat_name)
    end
  end
end