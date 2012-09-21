class StocksController < ApplicationController
  def index
  	select_sql = "products.name, products.taobao_id, products.status, stock_products.*"
  	@products = StockProduct.joins(:product).select(select_sql).where(seller_id: params[:seller_id]).page params[:page]
  end
end
