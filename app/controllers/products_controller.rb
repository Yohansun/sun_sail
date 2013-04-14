# -*- encoding : utf-8 -*-
class ProductsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize,:except => :fetch_products

  # cache_sweeper :product_sweeper
  # caches_action :show, :edit
  # caches_action :index, cache_path: Proc.new { |c| c.params }

  def index
    @products = current_account.products
    if params[:info_type].present? || params[:info].present?
      if params[:info_type] == "sku_info"
        @products = @products.joins(:skus).where("properties_name like ?", "%#{params[:info]}%")
      else
        @products = @products.where("#{params[:info_type]} like ? or #{params[:info_type]} = ?", "%#{params[:info].strip}%", params[:info].strip)
      end
    end
    if params[:category_id].present? && params[:category_id] != '0'
      @products = @products.where("category_id = ?", params[:category_id])
    end
    @searched_products = @products
    @products = @products.order("updated_at DESC").page(params[:page])
    respond_to do |format|
      format.xls
      format.html
    end
  end

  def show
    @product = current_account.products.find params[:id]
  end

  def new
    @product = current_account.products.new
  end

  def create
    @product = current_account.products.new params[:product]
    if @product.save
      if params[:product]['good_type'] == '2' && params[:child_iid].present?
        @product.create_packages(params[:child_iid])
      end
      redirect_to products_path
    else
      render new_product_path
    end
  end

  def edit
    @product = current_account.products.find params[:id]
  end

  def update
    @product = current_account.products.find params[:id]
    
    if params[:product]['good_type'] == '2' && params[:child_iid].present?
      @product.packages.delete_all
      @product.create_packages(params[:child_iid])
    end

    if @product.update_attributes(params[:product])
      redirect_to products_path
    else
      render action: :edit
    end
  end

  def destroy
    product = current_account.products.find(params[:id])
    product.destroy
    redirect_to products_path
  end

  def fetch_products
    @products = current_account.products.where(category_id: params[:category_id])
    respond_to do |format|
      format.js
    end
  end
end
