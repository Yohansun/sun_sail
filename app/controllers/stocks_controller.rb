# -*- encoding : utf-8 -*-
class StocksController < ApplicationController
  before_filter :authorize
  before_filter :set_warehouse

  def index
    condition_relation = StockProduct.where(default_search).includes(:seller,:product)
    condition_relation = condition_relation.where(StockProduct::STORAGE_STATUS[params[:storage_status]]).scoped if params[:storage_status].present?
    conditions ||= {}
    params[:search][:id_in] = params[:export_ids].split(',') if params[:export_ids].present?
    
    if params[:op_state].present?
      area_ids = Area.robot(params[:op_state],params[:op_city]).select(:id).map(&:id)
      conditions.merge!({:seller_sellers_areas_area_id_in => area_ids})
    elsif params[:op_district].present?
      conditions.merge!({:seller_sellers_areas_area_id_eq => params[:op_district]})
    end

    conditions = conditions.merge!(params[:search]) if params[:search].present?
    @search = condition_relation.search(conditions)
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
    @stock_products = StockProduct.where(default_search).joins(:product).joins(:sku).select(select_sql).order("stock_products.product_id")
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
    condition_relation = StockProduct.where(default_search)
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
    @stock_products = StockProduct.where(default_search).joins(:product).select("products.name as product_name,stock_products.product_id as stock_product_product_id,products.product_id as product_product_id")
    @stock_products_name = @stock_products.collect {|x| { id: x.stock_product_product_id, text: x.product_name}}
    @stock_products_id = @stock_products.collect {|x| { id: x.stock_product_product_id, text: x.product_product_id}}
    data = [@stock_products_name, @stock_products_id]

    render :json => data
  end
  
  def edit_depot
    @depot = current_account.sellers.first
  end
  
  def update_depot
    @depot = Seller.where(default_search).find params[:id]

    if @depot.update_attributes(params[:seller])
      redirect_to :action => "edit_depot"
    else
      render :action => "edit_depot"
    end
  end

  def edit_safe_stock
    value = params[:value]
    bool = false

    @stock_product = StockProduct.where(default_search).find params[:id]
    if @stock_product.blank?
    else
      if value =~ /\d/
        @stock_product = @stock_product.update_attribute(:safe_value, params[:value])
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

  #POST /warehouses/batch_update_safety_stock
  def batch_update_safety_stock
    @stock_products = StockProduct.where(default_search).where(:id => params[:stock_product_ids])
    safe_value = params[:safe_value].to_i
    @stock_products.update_all(:safe_value => safe_value)
    redirect_to({:action => :index,:warehouse_id => params[:warehouse_id]}.reject {|k,v| v.blank?})
  end

  #POST /warehouses/batch_update_activity_stock
  def batch_update_activity_stock
    @stock_product = StockProduct.where(default_search).find(params[:stock_product_ids].first)
    @stock_products = StockProduct.where(default_search).where(:product_id => @stock_product.product_id)
    activity = Integer(params[:activity]) rescue false
    if activity && activity > 0
      success,fails = StockProduct.batch_update_activity_stock(@stock_products,activity)
      flash[:notice] = "ID为#{success.join(',')} 更新可用库存#{activity}成功" if success.present?
      flash[:error] = "ID为#{fails.join(',')} 更新可用库存#{activity}失败" if fails.present?
    else
      flash[:error] =  "请输入大于 0 的整数"
    end
    redirect_to({:action => :index,:warehouse_id => params[:warehouse_id]}.reject {|k,v| v.blank?})
  end

  private
  def set_warehouse
    @warehouse = Seller.find(params[:warehouse_id]) rescue false
  end
  def default_search
    if @warehouse.blank?
      {account_id: current_account.id}
    else
      {account_id: current_account.id,:seller_id => @warehouse.id}
    end
  end
end
