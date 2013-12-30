# -*- encoding : utf-8 -*-
class CategoriesController < ApplicationController
  layout "management"

  before_filter :authorize #,:except => [:autocomplete,:new,:show,:edit,:deletes,
                                       # :category_templates,:product_templates,
                                       # :sku_templates]

  def index
    @categories = current_account.categories
    if params[:parent_id].present?
      @parents = current_account.categories.find(params[:parent_id]).self_and_ancestors
      @categories = @categories.where(parent_id: params[:parent_id])
    else
      @categories = @categories.roots
    end
    @categories = @categories.page(params[:page])
  end

  def new
    @category = current_account.categories.new
  end

  def show
    @categories = current_account.categories.where(parent_id: params[:id])
  end

  def edit
    @category = current_account.categories.find params[:id]
  end

  def create
    @category = current_account.categories.create params[:category]
    if @category.save
      if @category.parent_id.present?
        redirect_to categories_path(:parent_id => params[:parent_id])
      else
        redirect_to categories_path
      end
    else
      render :new
    end
  end

  def update
    @category = current_account.categories.find(params[:id])
    if @category.update_attributes(params[:category])
      if !@category.parent_id.blank?
        redirect_to categories_path(:parent_id => @category.parent_id)
      else
        redirect_to categories_path
      end
    else
      render :edit
    end
  end

  def destroy
    @category = current_account.categories.find params[:id]
    @category.destroy
    redirect_to categories_path
  end


  # BULK operation for multi-records
  def operations
    send(params[:ac])
  end


  def deletes
    @ids = params[:ids].split(",")
    parent_id = Category.find(@ids.first).parent_id
    Category.destroy(@ids)
    redirect_to categories_path(:parent_id=>parent_id)
  end

  # 选择本地商品三级联动
  def category_templates
    result = []
    items = current_account.categories.where("categories.parent_id IS NULL")
    items.each do |root|
      result += root.class.associate_parents(root.self_and_descendants).map do |c|
        { id: c.id, text: "#{'-' * c.level}#{c.name}"}
      end.compact
    end
    render json: result
  end

  def product_templates
    @products = current_account.products.where(category_id: params[:category_id]).collect {|p| { id: p.id, text: p.name}}
    render json: @products
  end

  def sku_templates
    product = current_account.products.find_by_id(params[:product_id])
    if product && product.skus
      @skus = product.skus.collect {|s| { id: s.id, text: (s.name.present? ? s.name : "标准款")}}
      render json: @skus
    else
      render json: []
    end
  end

end
