# -*- encoding : utf-8 -*-
class SalesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_only!

  def index
  end

  def show
    ##  时间参数及@sale初始化
    @sale = Sale.last
    TradeSetting.test_time = Time.now + 8.hour
    TradeSetting.test_time_2 = TradeSetting.test_time
    TradeSetting.frequency = 900   ## per second
    unless @sale
      @sale = Sale.create(name: "测试活动", earn_guess: 100000, start_at: TradeSetting.test_time, end_at: TradeSetting.test_time + 1.day)
    end
    @start_at = @sale.start_at.to_time
    @end_at = @sale.end_at.to_time

    if TradeSetting.test_time < @start_at
      @data = [[@start_at, 0, 0]]
    else
      frequency = TradeSetting.frequency
      if TradeSetting.test_time >= @end_at
        gap = @end_at.to_i - @start_at.to_i
      else
        gap = TradeSetting.test_time.to_i - @start_at.to_i
      end
      @data = []
      num = gap/frequency
      if gap%frequency > 0
        num += 1
      end

      (0..num).each do |counter|
        start_time = @start_at + counter * frequency
        p start_time
        if (counter + 1) * frequency > gap
          end_time = @end_at
        else
          end_time = @start_at + (counter + 1) * frequency
        end
        all_in_frequency = @sale.all_trade_fee(start_time, end_time)
        paid_in_frequency = @sale.paid_trade_fee(start_time, end_time)
        amount_all = all_in_frequency #@data.size > 0 ? @data.last[1] + all_in_frequency :
        amount_paid = paid_in_frequency #@data.size > 0 ? @data.last[2] + paid_in_frequency :
        # Rails.cache.write 'amount_all', amount_all
        # Rails.cache.write 'amount_paid', amount_paid
        @data << [start_time, amount_all, amount_paid]
        @progress_bar = (amount_paid/@sale.earn_guess*100).to_i
      end
    end
  end

  def add_node
    @sale = Sale.last
    frequency = TradeSetting.frequency
    time_now = TradeSetting.test_time_2
    start_time = time_now + frequency
    end_time = time_now + frequency * 2
    TradeSetting.test_time_2 += frequency

    all_in_frequency = @sale.all_trade_fee(start_time, end_time)
    paid_in_frequency = @sale.paid_trade_fee(start_time, end_time)
    amount_all = all_in_frequency # + (Rails.cache.read 'amount_all').to_f
    amount_paid =  paid_in_frequency # + (Rails.cache.read 'amount_paid').to_f
    # Rails.cache.write 'amount_all', amount_all
    # Rails.cache.write 'amount_paid', amount_paid
    progress_bar = (amount_paid/@sale.earn_guess*100).to_i
    respond_to do |format|
      format.json { render json: {year: start_time.year, month: start_time.month, day: start_time.day, hour: start_time.hour, min: start_time.min, amount: amount_all, amountall: amount_paid, progress_bar: progress_bar}}
    end
  end

  def new
    @sale = Sale.new
  end

  def create
    start_at = "#{params[:times][:start_date]} #{params[:times][:start_time]}".to_time
    end_at = "#{params[:times][:end_date]} #{params[:times][:end_time]}".to_time
    @sale = Sale.create(name: params[:sale][:name], earn_guess: params[:sale][:earn_guess], start_at: start_at, end_at: end_at)
    if @sale.save
      redirect_to "/sales/show"
    else
      render new_sale_path
    end
  end
end