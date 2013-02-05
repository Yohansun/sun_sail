class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_only!, :except => [:autocomplete]

  def index
    @categories = current_account.categories
    if params[:parent_id].present?
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

end