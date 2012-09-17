class StockProductsController < ApplicationController
  def new
  	@product = StockProduct.new
  end

  def create
  	@product = StockProduct.new params[:stock_product]
  	if @product.save!
  		redirect_to '/stocks'
  	else
  		redirect_to action: :new
  	end
  end

  def show
  	@product = StockProduct.find params[:id]
  	respond_to do |format|
  		format.json {render json: {name: @product.name, activity: @product.activity, actual: @product.actual}} 
  	end
  end

  def edit
  	@product = StockProduct.find params[:id]
  end

  def update
  	@product = StockProduct.find params[:id]
  	if @product.update_attributes(params[:stock_product])
  		redirect_to stocks_path
  	else
  		redirect_to action: :edit
  	end
  end

  def destroy
  	@product = StockProduct.find params[:id]
  	@product.destroy
  	redirect_to stocks_path
  end
end
