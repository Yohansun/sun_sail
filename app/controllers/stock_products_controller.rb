class StockProductsController < ApplicationController
  before_filter :authenticate_user!

  def new
  	@product = StockProduct.new
    @seller = Seller.find params[:seller_id]
  end

  def create
    @seller = Seller.find params[:seller_id]
  	@product = StockProduct.new params[:stock_product]
    @product.seller_id = params[:seller_id]
  	if @product.save
  		redirect_to seller_stocks_path(params[:seller_id])
  	else
  		render :new
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
    @seller = Seller.find params[:seller_id]
  	@product = StockProduct.find params[:id]
  end

  def update
    @seller = Seller.find params[:seller_id]
  	@product = StockProduct.find params[:id]
    Rails.logger.info params[:seller_id].inspect
  	if @product.update_attributes(params[:stock_product])
  		redirect_to seller_stocks_path(params[:seller_id])
  	else
  		render :edit
  	end
  end

  def destroy
  	@product = StockProduct.find params[:id]
  	@product.destroy
  	redirect_to seller_stocks_path params[:seller_id]
  end
end
