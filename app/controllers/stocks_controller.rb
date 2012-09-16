class StocksController < ApplicationController
  def index
  	@products = StockProduct.all
  end
end
