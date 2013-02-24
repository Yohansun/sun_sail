# -*- encoding : utf-8 -*-
class StocksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_stock_type, except: [:home]

  def index
    select_sql = "skus.*, products.name, products.outer_id, products.product_id, products.category_id, stock_products.*"
    @stock_products = current_account.stock_products.joins(:product).joins(:sku).select(select_sql).where(seller_id: @seller.id).order("stock_products.product_id")
    if params[:info_type].present? && params[:info].present?
      if params[:info_type] == "sku_info"
        @stock_products = @stock_products.where("skus.properties_name like ?", "%#{params[:info]}%")
      else
        @stock_products = @stock_products.where("products.#{params[:info_type]} like ?", "%#{params[:info].strip}%")
      end
    end
    if params[:category].present? && params[:category] != '0'
      @stock_products = @stock_products.where("products.category_id = ?", params[:category])
    end
    if params[:stock_state].present?
      case params[:stock_state]
      when 'safe'
        @stock_products = @stock_products.where("stock_products.activity < stock_products.safe_value")
      when 'max'
        @stock_products = @stock_products.where("stock_products.actual = stock_products.max ")
      else
        @stock_products = @stock_products.where("stock_products.actual != stock_products.max AND stock_products.activity >= stock_products.safe_value")
      end
    end
    @stock_products = @stock_products.where(" good_type != 2 OR good_type IS NULL ") if current_user.has_role?(:seller)
    @stock_products = @stock_products.page params[:page]
  end

  def home
    @enbaled_stocks_sellers =  current_account.sellers.where(has_stock: true)
    if params[:seller_name].present?
      @enbaled_stocks_sellers = @enbaled_stocks_sellers.where("sellers.name like ?", "%#{params[:seller_name].strip}%")
    end
    @enbaled_stocks_sellers = @enbaled_stocks_sellers.page params[:page]
  end

  private
  def check_stock_type
    if current_user.has_role?(:admin)
      @seller = current_account.sellers.find_by_id params[:seller_id]
    else
      @seller = current_user.seller
    end

    redirect_to root_path unless @seller && @seller.has_stock
  end
end
