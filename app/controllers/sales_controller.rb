# -*- encoding : utf-8 -*-
class SalesController < ApplicationController
  include SalesHelper
  before_filter :authenticate_user!
  before_filter :admin_only! 

  def index
    redirect_to "/sales/product_analysis"
  end

  def show
    ## 参数初始化
    @sale = Sale.last
    TradeSetting.test_time = Time.now + 8.hour
    TradeSetting.test_time_2 = TradeSetting.test_time
    TradeSetting.frequency = 600   ## per second
    unless @sale
      @sale = Sale.create(name: "测试活动", earn_guess: 100000, start_at: TradeSetting.test_time, end_at: TradeSetting.test_time + 1.day)
      render action: :edit
    end
    @start_at = @sale.start_at
    @end_at = @sale.end_at

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

    created_trades = TaobaoTrade.between(created: (@start_at.to_time - 8.hours)..(@end_at.to_time - 8.hours))
    paid_trades = TaobaoTrade.between(pay_time: (@start_at.to_time - 8.hours)..(@end_at.to_time - 8.hours))
    @amount_all = created_trades.try(:sum, :payment) || 0
    @amount_paid = paid_trades.try(:sum, :payment) || 0
    if @end_at.to_i - @start_at.to_i < 3.days.to_i
      created_map_reduce = created_trades.map_reduce(c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(p_map, p_reduce).out(inline: true)
    elsif @end_at.to_i - @start_at.to_i >= 3.days.to_i && @end_at.to_i - @start_at.to_i < 1.month.to_i
      created_map_reduce = created_trades.map_reduce(week_c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(week_p_map, p_reduce).out(inline: true)
    elsif @end_at.to_i - @start_at.to_i >= 1.month.to_i && @end_at.to_i - @start_at.to_i < 3.months.to_i
      created_map_reduce = created_trades.map_reduce(month_c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(month_p_map, p_reduce).out(inline: true)
    elsif @end_at.to_i - @start_at.to_i >= 3.months.to_i
      created_map_reduce = created_trades.map_reduce(year_c_map, c_reduce).out(inline: true)
      paid_map_reduce = paid_trades.map_reduce(year_p_map, p_reduce).out(inline: true)
    end

    # 非典型性循环
    enum_paid = paid_map_reduce.sort{|x,y| x["_id"].to_time.to_i <=> y["_id"].to_time.to_i}.to_enum
    enum_created = created_map_reduce.sort{|x,y| x["_id"].to_time.to_i <=> y["_id"].to_time.to_i}.to_enum
    @final_hash = {}
    begin
      current_paid = enum_paid.next
      current_created = enum_created.next
      p current_paid
      p current_created
      while(1)
        if current_created["_id"] == current_paid["_id"]
          @final_hash[current_created["_id"].to_time] = current_created["value"].merge(current_paid["value"])
          current_paid = enum_paid.next
          current_created = enum_created.next
        elsif current_created["_id"].to_time.to_i > current_paid["_id"].to_time.to_i
          while(current_created["_id"].to_time.to_i > current_paid["_id"].to_time.to_i)
            @final_hash[current_paid["_id"].to_time] = current_paid["value"].merge("created_fee" => 0.0)
            current_paid = enum_paid.next
          end
        else
          while(current_created["_id"].to_time.to_i < current_paid["_id"].to_time.to_i)
            @final_hash[current_created["_id"].to_time] = current_created["value"].merge("paid_fee" => 0.0)
            current_created = enum_created.next
          end
        end
      end
      rescue StopIteration
    end
    begin
      while(1)
        current_created = enum_created.next
        @final_hash[current_created["_id"].to_time] = current_created["value"].merge("paid_fee" => "0")
      end
      rescue StopIteration
    end
    begin
      while(1)
        current_paid = enum_paid.next
        @final_hash[current_paid["_id"].to_time] = current_paid["value"].merge("created_fee" => "0")
      end
      rescue StopIteration
    end

    p created_map_reduce.count

    @progress_bar = (@amount_paid/@sale.earn_guess*100).to_i
    Rails.cache.write 'amount_all', @amount_all
    Rails.cache.write 'amount_paid', @amount_paid
  end

  def add_node
    @sale = Sale.last
    frequency = TradeSetting.frequency
    time_now = TradeSetting.test_time_2
    start_time = time_now
    end_time = time_now + frequency
    TradeSetting.test_time_2 += frequency

    all_in_frequency = @sale.all_trade_fee(start_time, end_time)
    paid_in_frequency = @sale.paid_trade_fee(start_time, end_time)
    amount_all = all_in_frequency + (Rails.cache.read 'amount_all').to_f
    amount_paid =  paid_in_frequency + (Rails.cache.read 'amount_paid').to_f
    Rails.cache.write 'amount_all', amount_all
    Rails.cache.write 'amount_paid', amount_paid
    progress_bar = (amount_paid/@sale.earn_guess*100).to_i
    respond_to do |format|
      format.json { render json: {year: end_time.year, month: end_time.month, day: end_time.day, hour: end_time.hour, min: end_time.min, amount: all_in_frequency, amountall: paid_in_frequency, progress_bar: progress_bar, bill_money: amount_all, paid_money: amount_paid }}
    end
  end

  def edit
    @sale = Sale.last
    unless @sale
      @sale = Sale.create(name: "测试活动", earn_guess: 100000, start_at: Time.now + 8.hour, end_at: Time.now + 8.hour + 1.day)
    end
  end

  def update
    @sale = Sale.last
    start_at = "#{params[:times][:start_date]} #{params[:times][:start_time]}".to_time
    end_at = "#{params[:times][:end_date]} #{params[:times][:end_time]}".to_time

    if @sale.update_attributes(name: params[:sale][:name], earn_guess: params[:sale][:earn_guess], start_at: start_at, end_at: end_at)
      redirect_to "/sales/show"
    else
      render action: :edit
    end
  end

  def fetch_data
    respond_to do |format|
      format.js
    end
  end

  def product_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?

    if @start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
      @trades = TaobaoTrade.between(created: start_at..end_at).in(status: ["TRADE_FINISHED","FINISHED_L"])
      time_gap = (end_at - start_at).to_i
      @old_trades = TaobaoTrade.between(created: (start_at - time_gap.seconds)..start_at).in(status: ["TRADE_FINISHED","FINISHED_L"])
    else
      @trades = TaobaoTrade.between(created: 1.month.ago..Time.now).in(status: ["TRADE_FINISHED","FINISHED_L"])
      @old_trades = TaobaoTrade.between(created: 2.month.ago..1.month.ago).in(status: ["TRADE_FINISHED","FINISHED_L"])
    end

    if @trades && @old_trades
      @product_data = product_data(@trades, @old_trades)
    end
  end

  def area_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?

    if @start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.month.ago
      end_at = Time.now
    end
    @area_data = area_data(start_at, end_at)
  end

  def price_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?
    if@start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.month.ago
      end_at = Time.now
    end
    @price_data = price_data(start_at, end_at)
  end

  def time_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?
    if @start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.month.ago
      end_at = Time.now  
    end
    @time_data = time_data(start_at, end_at)
  end

  def customer_analysis
  end

  def frequency_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?
    if @start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.month.ago
      end_at = Time.now
    end
    @frequency_data = frequency_data(start_at, end_at)
  end

  def univalent_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?
    if @start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.month.ago
      end_at = Time.now
    end
    @univalent_data = univalent_data(start_at, end_at)
  end

end