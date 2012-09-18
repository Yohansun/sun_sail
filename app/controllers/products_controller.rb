# -*- encoding : utf-8 -*-
class ProductsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @products = Product.all
  end

  def show
    @product = Product.find params[:id]
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new params[:product]
    if @product.save
      redirect_to products_path
    else
      redirect_to new_product_path, :notice => @product.errors.full_messages
    end
  end

  def edit
    @product = Product.find params[:id]
  end

  def update
    @product = Product.find params[:id]
    if @product.update_attributes(params[:product])
      redirect_to products_path
    else
      redirect_to action: :edit, :notice => @product.errors.full_messages
    end
  end
end
