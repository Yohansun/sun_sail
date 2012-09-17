# -*- encoding : utf-8 -*-
class StockHistoryController < ApplicationController
	def index
		@history = StockHistory.where(seller_id: params[:seller_id]).all
	end

  def create
  	@history = StockHistory.new params[:stock_history]
  	@product = StockProduct.find params[:stock_history]['stock_product_id']
  	number = params[:stock_history]['number'].to_i

  	case params[:stock_history]['operation']
  	when '入库'
  		@product.activity += number
  		@product.actual += number
  	when '出库'
  		@product.activity -= number
  		@product.actual -= number
  	end

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
