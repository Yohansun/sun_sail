# -*- encoding : utf-8 -*-
class StocksController < ApplicationController
  before_filter :authorize

  def index
    condition_relation = current_account.stock_products
    
    condition_relation = condition_relation.where(StockProduct::STORAGE_STATUS[params[:storage_status]]).scoped if params[:storage_status].present?
    params[:search] ||= {}
    params[:search][:id_in] = params[:export_ids].split(',') if params[:export_ids].present?
    
    @search = condition_relation.search(params[:search])
    @stock_products = @search.page params[:page]
    @count = @search.count
    respond_to do |format|
      format.html
      format.xls
    end
  end
  
  
  def old
    select_sql = "skus.*, products.name, products.outer_id, products.product_id, products.category_id, stock_products.*"
    @stock_products = current_account.stock_products.joins(:product).joins(:sku).select(select_sql).order("stock_products.product_id")
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
    
    @stock_products = @stock_products.where(" good_type != 2 OR good_type IS NULL ") if current_user.seller.present?
    @stock_products = @stock_products.page params[:page]
    
  end
end
