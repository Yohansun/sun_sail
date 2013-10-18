# -*- encoding : utf-8 -*-
module PagesHelper
  include SalesHelper
  include TradesHelper
  def pages_hash
    {
      "new_add_trades"                => new_add_trades_int,               #今日新增订单
      "new_profit"                    => new_profit_float,                 #今日新进收益
      "new_top_one_district"          => new_top_one_district_string,      #今日买家集中省份TOP1
      "new_hot_product"               => new_hot_product_string,           #今日热卖商品
      "sale_chart"                    => sale_chart_hash,                  #销售分析
      "frequency_range"               => frequency_range_array,            #购买频次分析
      "time_range"                    => time_range_array,                 #购买时段分析
      "trades_percent_analysis"       => trades_percent_analysis_hash,     #订单分析
      "customers_percent_analysis"    => customers_percent_analysis_hash   #顾客分析
    }
  end

  def new_add_trades_int
    current_account.trades.between(created: Time.now.beginning_of_day..Time.now).count
  end

  def new_profit_float
    today_summary[5]
  end

  def new_top_one_district_string
    area_data(1.day.ago,
              Time.now)[0][0] rescue "暂无"
  end

  def new_hot_product_string
    current_account.products.find_by_num_iid(product_data(1.day.ago,
                                             Time.now)[0].first[0]).name rescue "暂无"
  end

  def sale_chart_hash
    generate_sale_chart_data(1.month.ago, Time.now)[2]
  end

  def frequency_range_array
    frequency_data(1.month.ago, Time.now)
  end

  def time_range_array
    time_data(1.month.ago, Time.now)
  end

  def trades_percent_analysis_hash
    total_trades = current_account.trades.between(created: 1.month.ago..Time.now)
    total_trades_count = total_trades.count
    if total_trades_count == 0
      paid_percent, unpaid_percent, undelivered_percent = [0,0,0]
    else
      paid_percent = (total_trades.ne(pay_time: nil).count.to_f / total_trades_count).round(2)*100
      unpaid_percent = (total_trades.where(pay_time: nil).count.to_f / total_trades_count).round(2)*100
      undelivered_percent = (total_trades.and(delivered_at: nil, consign_time: nil).count.to_f / total_trades_count).round(2)*100
    end
    {"paid_percent" => paid_percent,
     "unpaid_percent" => unpaid_percent,
     "undelivered_percent" => undelivered_percent}
  end

  def customers_percent_analysis_hash
    total_customers = Customer.search(:transaction_histories_created_at_gt => 1.month.ago).where(account_id: current_account.id)
    total_customers_count = total_customers.count
    if total_customers_count == 0
      potential_percent, new_percent, familiar_percent = [0,0,0]
    else
      potential_percent = (total_customers.potential.count.to_f / total_customers_count).round(2)*100
      new_percent = (total_customers.between(created_at: Time.now.beginning_of_day..Time.now).count.to_f / total_customers_count).round(2)*100
      familiar_percent = (total_customers.search(:transaction_histories_status_in => Trade::StatusHash["succeed_array"]).count.to_f / total_customers_count).round(2)*100
    end
    {"potential_percent" => potential_percent,
     "new_percent" => new_percent,
     "familiar_percent" => familiar_percent}
  end

  def recent_trades
    if current_user.has_role?(:admin)
      trades = current_account.trades.between(created: 1.day.ago..Time.now)
      unusual_trades = trades.where(:unusual_states.elem_match => {repaired_at: nil}).only(:tid, :unusual_states).limit(5)
    else
      trades = current_account.trades.between(created: 1.day.ago..Time.now).where(operator_id: current_user.id)
      unusual_trades = trades.where(:unusual_states.elem_match => {:repair_man => current_user.name, repaired_at: nil}).only(:tid, :unusual_states).limit(5)
    end
    #Need more orders
    undispatched_trades = trades.where({:status.in => Trade::StatusHash["paid_not_deliver_array"],
                                        seller_id: nil,
                                        has_unusual_state: false,
                                        :pay_time.ne => nil}).only(:tid, :taobao_orders, :payment).limit(5)
    undelivered_trades = trades.where({:dispatched_at.ne => nil,
                                       :status.in => Trade::StatusHash["paid_not_deliver_array"],
                                       has_unusual_state: false}).only(:tid, :taobao_orders, :payment).limit(5)
    delivered_trades = trades.where(:status.in => Trade::StatusHash["paid_and_delivered_array"],
                                    has_unusual_state: false).only(:tid, :taobao_orders, :payment).limit(5)
    [undispatched_trades, undelivered_trades, delivered_trades, unusual_trades]
  end

end

