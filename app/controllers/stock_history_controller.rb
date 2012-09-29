# -*- encoding : utf-8 -*-
class StockHistoryController < ApplicationController
	def index
    @history = StockHistory

    unless params[:bdate].blank? && params[:edate].blank?
      begin_time = "#{params[:bdate]} #{params[:btime] || '00:00:00'}".to_time(:local)
      end_time = "#{params[:edate]} #{params[:etime] || '00:00:00'}".to_time(:local)
      @history = @history.where(created_at: begin_time..end_time)
    end

		@history = @history.where(seller_id: params[:seller_id], stock_product_id: params[:stock_product_id]).page params[:page]
	end

  def create
  	@history = StockHistory.new params[:stock_history]
  	@product = StockProduct.find params[:stock_history]['stock_product_id']
  	number = params[:stock_history]['number'].to_i

  	number = if params[:stock_history]['operation'] == '入库'
  		number
  	elsif params[:stock_history]['operation'] == '出库'
  		-number
    else
      0
  	end

    @product.activity += number
    @product.actual += number

  	@history.user_id = current_user.id
    @history.seller_id = params[:seller_id]

  	if @product.save && @history.save
  		@flag = true
  	end
  end

  def show
  	@history = StockHistory.find params[:id]
    @product = @history.stock_product.product
  end
end
