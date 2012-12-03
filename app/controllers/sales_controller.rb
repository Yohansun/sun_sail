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
    TradeSetting.frequency = 900   ## per second
    @amount_all = 0
    @amount_paid = 0
    unless @sale
      @sale = Sale.create(name: "测试活动", earn_guess: 100000, start_at: TradeSetting.test_time, end_at: TradeSetting.test_time + 1.day)
      render action: :edit
    end
    @start_at = @sale.start_at.to_time
    @end_at = @sale.end_at.to_time
    @data = [[@start_at, 0, 0]]

    ## 分时间段显示不同情况
    unless TradeSetting.test_time < @start_at
      frequency = TradeSetting.frequency
      if TradeSetting.test_time >= @end_at
        gap = @end_at.to_i - @start_at.to_i
      else
        gap = TradeSetting.test_time.to_i - @start_at.to_i
      end
      num = gap/frequency

      (0..num).each do |counter|
        unless num == counter && gap%frequency == 0
          start_time = @start_at + counter * frequency
          if num == counter && gap%frequency > 0
            if TradeSetting.test_time >= @end_at
              end_time = @end_at
            else
              end_time = TradeSetting.test_time
            end
          else
            end_time = @start_at + (counter + 1) * frequency
          end
          all_in_frequency = @sale.all_trade_fee(start_time, end_time)
          paid_in_frequency = @sale.paid_trade_fee(start_time, end_time)
          @amount_all += all_in_frequency
          @amount_paid += paid_in_frequency
          @data << [end_time, all_in_frequency, paid_in_frequency]
        end
      end
    end
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
    render "/sales/product_analysis"
  end

  def real_product_analysis
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
      @trades = TaobaoTrade.between(created: 1.week.ago..Time.now).in(status: ["TRADE_FINISHED","FINISHED_L"])
      @old_trades = TaobaoTrade.between(created: 2.week.ago..1.week.ago).in(status: ["TRADE_FINISHED","FINISHED_L"])
    end

    if @trades && @old_trades
      @product_data = product_data(@trades, @old_trades)
    end
    render "/sales/real_product_analysis"
  end

  def area_analysis
    render "/sales/area_analysis"
  end

  def real_area_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?

    if @start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.week.ago
      end_at = Time.now
    end
    @area_data = area_data(start_at, end_at)
    render "/sales/real_area_analysis"
  end

  def price_analysis
    render "/sales/price_analysis"
  end

  def real_price_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?
    if@start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.week.ago
      end_at = Time.now
    end
    @price_data = price_data(start_at, end_at)
    render "/sales/real_price_analysis"
  end

  def time_analysis
    render "/sales/time_analysis"
  end

  def real_time_analysis
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date = params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time = params[:end_time] if params[:end_time].present?
    if @start_date && @end_date
      start_at = "#{@start_date} #{@start_time}".to_time(:local)
      end_at = "#{@end_date} #{@end_time}".to_time(:local)
    else
      start_at = 1.week.ago
      end_at = Time.now  
    end
    @time_data = time_data(start_at, end_at)
  end

  def customer_analysis
  end
  
  def frequency_analysis
    render "/sales/frequency_analysis"
  end
  def real_frequency_analysis
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
    render "/sales/real_frequency_analysis"
  end

  def univalent_analysis
    render "/sales/univalent_analysis"
  end
  def real_univalent_analysis
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
    render "/sales/real_univalent_analysis"
  end

end