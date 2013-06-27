# -*- encoding : utf-8 -*-
class StocksController < ApplicationController
  before_filter :authorize

  def index
    condition_relation = current_account.stock_products
    
    condition_relation = condition_relation.where(StockProduct::STORAGE_STATUS[params[:storage_status]]).scoped if params[:storage_status].present?
    params[:search] ||= {}
    params[:search][:id_in] = params[:export_ids].split(',') if params[:export_ids].present?
    
    @search = condition_relation.search(params[:search])
    @number = 20
    @number = params[:number] if params[:number].present?
    @stock_products = @search.page(params[:page]).per(@number)
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

  def safe_stock
    condition_relation = current_account.stock_products
    condition_relation = condition_relation.where(StockProduct::STORAGE_STATUS[params[:storage_status]]).scoped if params[:storage_status].present?
    
    params[:product_id_eq] ||= nil
    params[:stock] = {"product_id_eq"=> params[:product_id_eq]}
    if params[:stock].blank?
      @search = condition_relation.search
    else
      @search = condition_relation.search(params[:stock])
    end

    @stock_products = @search.page params[:page]
    @count = @search.count
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def change_product_type
    @stock_products_name = current_account.stock_products.collect {|x| { id: x.product_id, text: x.product.name}}
    @stock_products_id = current_account.stock_products.collect {|x| { id: x.product_id, text: x.product.product_id}}
    data = [@stock_products_name, @stock_products_id]

    render :json => data
  end
  
  def edit_depot
    @depot = current_account.sellers.first
  end
  
  def update_depot
    @depot = current_account.sellers.find_by_id params[:id]
    if @depot.update_attributes(params[:seller])
      redirect_to :action => "edit_depot"
    else
      render :action => "edit_depot"
    end
  end

  def edit_safe_stock
    stock_product_id = params[:id]
    value = params[:value]
    bool = false

    @stock_product = StockProduct.find(stock_product_id)
    if @stock_product.blank?
    else
      if value =~ /\d/
        @stock_product = @stock_product.update_attribute(:safe_value, value)
        if @stock_product
          bool = true
        end
      end
    end

    if bool
      result = "ok"
    else
      result = 'err'
    end
    
    render :text => result
  end

  #POST /warehouses/barch_update_safety_stock
  def batch_update_safety_stock
    @stock_products = StockProduct.where(:account_id => current_account.id,:id => params[:stock_product_ids])
    safe_value = params[:safe_value].to_i
    @stock_products.update_all(:safe_value => safe_value)
    redirect_to :action => :index
  end

end
