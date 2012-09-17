# -*- encoding : utf-8 -*-
class ProductsController < ApplicationController

  def index
    @products = Product.all
  end

  # def show
  #   @product = Product.find params[:id]
  # end

  # def create
  #   @product = Product.create
  # end

  # def update
  #   @product = Product.find params[:id]
  # end
end
