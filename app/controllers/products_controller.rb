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
    featrues = params[:product].delete('features')
    featrues.delete("")
    @product.features = featrues.join(',')
    if @product.save
      redirect_to products_path
    else
      render new_product_path
    end
  end

  def edit
    @product = Product.find params[:id]
    @product.features = @product.features.split(',')
  end

  def update
    @product = Product.find params[:id]
    featrues = params[:product].delete('features')
    featrues.delete("")
    if @product.update_attributes(params[:product])
      @product.features = featrues.join(',')
      @product.save
      redirect_to products_path
    else
      render action: :edit, :notice => @product.errors.full_messages
    end
  end

  def destroy
    Product.delete(params[:id])
    redirect_to products_path
  end
end
