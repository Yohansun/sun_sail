class StockProductsController < ApplicationController
  def new
  	@product = StockProduct.new
    @seller = Seller.find params[:seller_id]
  end

  def create
  	@product = StockProduct.new params[:stock_product]
  	if @product.save!
  		redirect_to seller_stocks_path(params[:seller_id])
  	else
  		redirect_to action: :new
  	end
  end

  def show
  	@stock_product = StockProduct.find params[:id]
    @product = @stock_product.product
  	respond_to do |format|
  		format.json {render json: {name: @product.name, activity: @stock_product.activity, actual: @stock_product.actual}} 
  	end
  end

  def edit
  	@product = StockProduct.find params[:id]
    @seller = Seller.find params[:seller_id]
  end

  def update
  	@product = StockProduct.find params[:id]
    Rails.logger.info params[:seller_id].inspect
  	if @product.update_attributes(params[:stock_product])
  		redirect_to seller_stocks_path(params[:seller_id])
  	else
  		redirect_to action: :edit
  	end
  end

  def destroy
  	@product = StockProduct.find params[:id]
  	@product.destroy
  	redirect_to seller_stocks_path params[:seller_id]
  end
end
