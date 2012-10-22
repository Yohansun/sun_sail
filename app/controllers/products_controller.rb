# -*- encoding : utf-8 -*-
class ProductsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_only!

  def index
    @products = Product
    if params[:product].present?
      unless params[:product][:info_type].blank? || params[:product][:info].blank?
        @products = @products.where("#{params[:product][:info_type]} like ?", "%#{params[:product][:info].strip}%")
      end
      unless params[:product][:item_level].blank?
        @products = @products.where("level_id = ?", params[:product][:item_level])
      end
      unless params[:product][:item_status].blank?
        @products = @products.where("status = ?", params[:product][:item_status])
      end
      unless params[:product][:item_category].blank?
        @products = @products.where("category_id = ?", params[:product][:item_category])
      end
      unless params[:product][:item_quantity].blank?
        @products = @products.where("quantity_id = ?", params[:product][:item_quantity])
      end
      unless params[:product][:item_features] == [""]
        feature_ids = params[:product][:item_features].collect{|i| i.to_i}
        @products = @products.joins(:feature_product_relationships).where("feature_product_relationships.feature_id in (#{feature_ids.join(',')})").uniq
      end
    end
    @searched_products = @products
    @products = @products.page(params[:page])
    respond_to do |format|
      format.xls
      format.html
    end
  end

  def show
    @product = Product.find params[:id]
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new params[:product]

    if params[:product]['good_type'] == '2' && params[:child_iid].present?
      @product.create_packages(params[:child_iid])
    end

    if @product.save
      redirect_to products_path
    else
      render new_product_path
    end
  end

  def edit
    @product = Product.find params[:id]
  end

  def change_status
    @product = Product.find params[:product_id]
    if @product.status == "SOLD_OUT"
      @product.status = "ON_SALE"
    elsif @product.status == "ON_SALE"
      @product.status = "SOLD_OUT"
    end
    @product.save
  end

  def update
    @product = Product.find params[:id]

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
    Product.delete(params[:id])
    redirect_to products_path
  end

  def fetch_products
    @products = Product.where(category_id: params[:category_id])
    respond_to do |format|
      format.js
    end
  end
end
