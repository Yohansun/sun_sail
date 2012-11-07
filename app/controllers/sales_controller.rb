# -*- encoding : utf-8 -*-
class SalesController < ApplicationController

  def index
  end

  def show
    @sale = Sale.last

    gap = 2.hour

    @data = []
    num = ((@sale.end_at - @sale.start_at) / gap).to_i
    (0..num).each do |counter|
      start_time = @sale.start_at + counter * gap
      end_time = @sale.start_at + (counter + 1) * gap

      amount_in_gap = Sale.total_fee_by_time(start_time, end_time)
      amountall = @data.size > 0 ? @data.last[2] + amount_in_gap : amount_in_gap

      @data << [start_time, amountall, amountall]
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


