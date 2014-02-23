# -*- encoding : utf-8 -*-
class SalesController < ApplicationController
  before_filter :authorize
  include SalesHelper
  include MagicReport

  def summary
    @start_time = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time = (params[:end_time].to_time rescue nil) || Time.now
    @final_hash = generate_sale_chart_data(@start_time, @end_time)[2]
  end

  def show
    ## 参数初始化
    @sale = current_account.sales.last
    current_account.settings.test_time = Time.now + 8.hour
    current_account.settings.test_time_2 = current_account.settings.test_time
    current_account.settings.frequency = 600  ## per second
    unless @sale
      @sale = current_account.sales.create(name: "测试活动", earn_guess: 100000, start_at: current_account.settings.test_time, end_at: current_account.settings.test_time + 1.day)
      render action: :edit
    end
    @start_at = @sale.start_at
    @end_at = @sale.end_at

    @amount_all,@amount_paid,@final_hash = generate_sale_chart_data(@start_at, @end_at)

    @progress_bar = (@amount_paid/@sale.earn_guess*100).to_i
    Rails.cache.write 'amount_all', @amount_all
    Rails.cache.write 'amount_paid', @amount_paid
  end

  def add_node
    @sale = current_account.sales.last
    frequency = current_account.settings.frequency
    time_now = current_account.settings.test_time_2
    start_time = time_now
    end_time = time_now + frequency
    current_account.settings.test_time_2 = current_account.settings.test_time_2 + frequency

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
    @sale = current_account.sales.last
    unless @sale
      @sale = current_account.sales.create(name: "测试活动", earn_guess: 100000, start_at: Time.now + 8.hour, end_at: Time.now + 8.hour + 1.day)
    end
  end

  def update
    @sale = current_account.sales.last
    start_at = "#{params[:times][:start_date]} #{params[:times][:start_time]}".to_time
    end_at = "#{params[:times][:end_date]} #{params[:times][:end_time]}".to_time

    if @sale.update_attributes(name: params[:sale][:name], earn_guess: params[:sale][:earn_guess], start_at: start_at, end_at: end_at)
      redirect_to "/sales/show"
    else
      render action: :edit
    end
  end

  # def fetch_data
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  def product_analysis
    @start_time   = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time     = (params[:end_time].to_time rescue nil) || 1.second.ago
    @product_data = product_data(@start_time, @end_time) rescue []
  end

  def taobao_product_analysis
    @start_time          = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time            = (params[:end_time].to_time rescue nil) || 1.second.ago
    @taobao_product_data = [top_ten_with_category_analysis(current_account, @start_time, @end_time)]
    @taobao_product_data << category_comparism_analysis(current_account, @start_time, @end_time)
    @taobao_product_data << product_num_with_seller_analysis(current_account, @start_time, @end_time)
  end

  def area_analysis
    @start_time = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time   = (params[:end_time].to_time rescue nil) || 1.second.ago
    @area_data  = area_data(@start_time, @end_time)
  end

  def price_analysis
    @start_time = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time   = (params[:end_time].to_time rescue nil) || 1.second.ago
    @price_data = price_data(@start_time, @end_time)
  end

  def time_analysis
    @start_time = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time   = (params[:end_time].to_time rescue nil) || 1.second.ago
    @time_data  = time_data(@start_time, @end_time)
  end

  def frequency_analysis
    @start_time     = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time       = (params[:end_time].to_time rescue nil) || 1.second.ago
    @frequency_data = frequency_data(@start_time, @end_time)
  end

  def univalent_analysis
    @start_time     = (params[:start_time].to_time rescue nil) || 1.month.ago
    @end_time       = (params[:end_time].to_time rescue nil) || 1.second.ago
    @univalent_data = univalent_data(@start_time, @end_time)
  end

  ## 淘宝商品分析报表导出
  ExportTaobaoProductAnalysis.each do |analysis|
    define_method analysis do
      start_time     = (params[:start_time].to_time rescue nil) || 1.month.ago
      end_time       = (params[:end_time].to_time rescue nil) || 1.second.ago
      @analysis_data = send(analysis.gsub("export_", "").to_sym, current_account, start_time, end_time)
      respond_to do |format|
        format.xls
      end
    end
  end
end