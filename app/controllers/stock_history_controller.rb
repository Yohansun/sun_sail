# -*- encoding : utf-8 -*-
class StockHistoryController < ApplicationController
  before_filter :authenticate_user!

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
    else
      if @product.errors[:activity].first == '数量不能小于零'
        @error_message = '当前库存商品不足，建议调整出库数量'
      elsif @product.errors[:activity].first == '数量必须小于满仓值'
        @error_message = '库存数量必须小于满仓值，建议调整入库数量'
      end
  	end
  end

  def show
  	@history = StockHistory.find params[:id]
    @product = @history.stock_product.product
  end
end
