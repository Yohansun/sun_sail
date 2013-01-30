class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_only!, :except => [:autocomplete]

  def index
    @categories = Category
    if params[:parent_id].present?
      @categories = @categories.where(parent_id: params[:parent_id])
    else
      @categories = @categories.roots
    end
    @categories = @categories.page(params[:page])
  end

  def new
    @category = Category.new
  end

  def show
    @categories = Category.where(parent_id: params[:id])
  end

  def edit
    @category = Category.find params[:id]
  end

  def create
    @category = Category.create params[:category]
    if @category.save!
      p @category.inspect
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
    @category = Category.find(params[:id])
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
    @category = Category.find params[:id]
    @category.destroy
    redirect_to categories_path
  end

end