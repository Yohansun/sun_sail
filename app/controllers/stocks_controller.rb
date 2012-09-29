class StocksController < ApplicationController

	before_filter :check_stock_type, except: [:home]

  def index
  	select_sql = "products.name, products.taobao_id, products.status, stock_products.*"
  	@products = StockProduct.joins(:product).select(select_sql).where(seller_id: params[:seller_id]).page params[:page]
  end

  def home
    @stocks = Stock
    if params[:stock_name].present?
      @stocks = @stocks.where(name: params[:stock_name])
    end
    @stocks = @stocks.page params[:page]
  end

  private
  def check_stock_type
		@seller = Seller.find_by_id params[:seller_id]
		redirect_to sellers_path unless @seller && @seller.has_stock
	end
end
