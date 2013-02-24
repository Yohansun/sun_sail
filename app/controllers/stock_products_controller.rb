# -*- encoding : utf-8 -*-
class StockProductsController < ApplicationController
  before_filter :authenticate_user!

  def index
  end

  def search
    area_id = nil
    where_sql = "stock_products.product_id = #{params[:product][:id].to_i}"
    if current_user.has_role?(:seller) && current_user.seller
      where_sql += " and sellers.id = #{current_user.seller.id}"
    end
    if params[:area_name_tree].present?
      area_id = params[:area_name_tree].to_i
    elsif params[:area_name_two].present?
      area_id = params[:area_name_two].to_i
    elsif params[:area_name_one].present?
      area_id = params[:area_name_one].to_i
    elsif params[:name_all].present?
      area_id = params[:name_all].to_i
    end
    if area_id.present?
      area = Area.find_by_id area_id
      unless area
        if params[:format]
          @sellers = current_account.sellers.joins(:sellers_areas, :stock_products).select('stock_products.id AS sp_id, stock_products.activity, sellers.name, sellers_areas.area_id AS a_name').where(where_sql)
        else
          @sellers = current_account.sellers.joins(:sellers_areas, :stock_products).select('stock_products.id AS sp_id, stock_products.activity, sellers.name, sellers_areas.area_id AS a_name').where(where_sql).page params[:page]
        end
      else
        leaves = area.leaves
        leaves << area if leaves.blank?
        where_sql += " AND areas.id in (#{leaves.map(&:id).join(',')})"
        if params[:format]
          @sellers = current_account.sellers.joins(:areas, :stock_products).select('stock_products.id AS sp_id, stock_products.activity, sellers.name, areas.id AS a_name').where(where_sql)
        else
          @sellers = current_account.sellers.joins(:areas, :stock_products).select('stock_products.id AS sp_id, stock_products.activity, sellers.name, areas.id AS a_name').where(where_sql).page params[:page]
        end
      end
    else
      if params[:format]
        @sellers = current_account.sellers.joins(:sellers_areas, :stock_products).select('stock_products.id AS sp_id, stock_products.activity, sellers.name, sellers_areas.area_id AS a_name').where(where_sql)
      else
        @sellers = current_account.sellers.joins(:sellers_areas, :stock_products).select('stock_products.id AS sp_id, stock_products.activity, sellers.name, sellers_areas.area_id AS a_name').where(where_sql).page params[:page]
      end

    end
    respond_to do |format|
      format.xls
      format.html { render :index }
    end

  end

  def new
    @product = current_account.stock_products.new
    @seller = current_account.sellers.find params[:seller_id]
  end

  def create
    @seller = current_account.sellers.find params[:seller_id]
    @product = current_account.stock_products.new params[:stock_product]
    @product.seller_id = params[:seller_id]
    if @product.save
      redirect_to seller_stocks_path(params[:seller_id])
    else
      render :new
    end
  end

  def show
    @stock_product = current_account.stock_products.find params[:id]
    @product = @stock_product.product
    respond_to do |format|
      format.json {render json: {name: @product.name, activity: @stock_product.activity, actual: @stock_product.actual}}
    end
  end

  def edit
    @seller = current_account.sellers.find params[:seller_id]
    @product = current_account.stock_products.find params[:id]
  end

  def update
    @seller = current_account.sellers.find params[:seller_id]
    @product = current_account.stock_products.find params[:id]
    # Rails.logger.info params[:seller_id].inspect
    if @product.update_attributes params[:stock_product]
      redirect_to seller_stocks_path(params[:seller_id])
    else
      render :edit
    end
  end

  def destroy
    @product = current_account.stock_products.find params[:id]
    @product.destroy
    redirect_to seller_stocks_path params[:seller_id]
  end

  def change_stock_product
    product_id = params[:product_id].first
    product  = Product.find_by_id product_id
    if product
      @product_id = product_id
      respond_to do |format|
        format.js
      end
    else
      render nothing: true
    end
  end

end
