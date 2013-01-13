class StocksController < ApplicationController
  before_filter :authenticate_user!

	before_filter :check_stock_type, except: [:home]

  def index
  	select_sql = "products.name, products.iid, products.taobao_id, products.category_id, products.status, stock_products.*"
  	@products = StockProduct.joins(:product).select(select_sql).where(seller_id: @seller.id)

    if params[:info_type].present? && params[:info].present?
      @products = @products.where("products.#{params[:info_type]} like ?", "%#{params[:info].strip}%")
    end

    if params[:category].present? && params[:category] != '0'
      @products = @products.where("products.category_id = ?", params[:category])
    end

    if params[:stock_state].present?
      case params[:stock_state]
      when 'safe'
        @products = @products.where("stock_products.activity < stock_products.safe_value")
      when 'max'
        @products = @products.where("stock_products.actual = stock_products.max ")
      else
        @products = @products.where("stock_products.actual != stock_products.max AND stock_products.activity >= stock_products.safe_value")
      end
    end

    @products = @products.page params[:page]
  end

  def home
    @enbaled_stocks_sellers =  Seller.where(has_stock: true)
    if params[:seller_name].present?
      @enbaled_stocks_sellers = @enbaled_stocks_sellers.where("sellers.name like ?", "%#{params[:seller_name].strip}%")
    end
    @enbaled_stocks_sellers = @enbaled_stocks_sellers.page params[:page]
  end

  private
  def check_stock_type
    if current_user.has_role?(:admin)
      @seller = Seller.find_by_id params[:seller_id]
    else
      @seller = current_user.seller
    end

		redirect_to root_path unless @seller && @seller.has_stock
	end
end
