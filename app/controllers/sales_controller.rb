# -*- encoding : utf-8 -*-
class SalesController < ApplicationController

  def index
  end

  def show
    @sale = Sale.last
    TradeSetting.test_time = Time.now
    TradeSetting.test_time_2 = TradeSetting.test_time

    # if Time.now < @sale.start_at
      @data = [[Time.now, 0, 0]]
    # elsif Time.now >= @sale.end_at
    #   frequency = TradeSetting.gap_time               ## per second
    #   gap = @sale.end_at.to_i - @sale.start_at.to_i
    #   @data = []
    #   num = gap/frequency
    #   if gap%frequency > 0
    #     num += 1
    #   end
    #   (0..num).each do |counter|
    #     start_time = @sale.start_at + counter * frequency
    #     if (counter + 1) * frequency > gap
    #       end_time = @sale.end_at
    #     else
    #       end_time = @sale.start_at + (counter + 1) * frequency
    #     end

    #     all_in_frequency = @sale.all_trade_fee(start_time, end_time)
    #     paid_in_frequency = @sale.paid_trade_fee(start_time, end_time)
    #     amount_all = @data.size > 0 ? @data.last[1] + all_in_frequency : all_in_frequency
    #     amount_paid = @data.size > 0 ? @data.last[2] + paid_in_frequency : paid_in_frequency

    #     @data << [start_time, amount_all, amount_paid]
    #   end
    # else
    # end

  end

  def add_node
    #@sale = Sale.last
    frequency = TradeSetting.gap_time
    time_now = TradeSetting.test_time_2 #######trouble here
    start_time = time_now + frequency
    end_time = time_now + frequency * 2
    TradeSetting.test_time_2 += frequency

    all_in_frequency = 0#@sale.all_trade_fee(start_time, end_time)
    paid_in_frequency = 0#@sale.paid_trade_fee(start_time, end_time)
    amount_all = all_in_frequency
    amount_paid = paid_in_frequency

    respond_to do |format|
      format.json { render json: {year: start_time.year, month: start_time.month, day: start_time.day, hour: start_time.hour, min: start_time.min, amount: amount_all, amountall: amount_paid}}
    end
  end

  def new
    @sale = Sale.new
  end

  def create
    start_at = "#{params[:times][:start_date]} #{params[:times][:start_time]}".to_time(form = :local)
    end_at = "#{params[:times][:end_date]} #{params[:times][:end_time]}".to_time(form = :local)
    @sale = Sale.create(name: params[:sale][:name], earn_guess: params[:sale][:earn_guess], start_at: start_at, end_at: end_at)
    if @sale.save
      redirect_to "/sales/show"
    else
      render sales_new_path
    end
  end
end