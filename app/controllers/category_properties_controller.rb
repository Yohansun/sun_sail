# encoding: utf-8
class CategoryPropertiesController < ApplicationController

  layout "management"
  
  def index
    @category_properties = CategoryProperty.page(params[:page], :per_page=>20)
  end
  
  def new
    @category_property = CategoryProperty.new(status:true)
  end
  
  def create
    @category_property = CategoryProperty.new(params[:category_property])
    if @category_property.save
      flash[:success] = "保存成功"
      redirect_to :category_properties
    else
      render  :action=>:new
    end
  end
  
  def edit
    @category_property = CategoryProperty.find(params[:id])
  end
  
  def update
    @category_property = CategoryProperty.find(params[:id])
    if @category_property.update_attributes(params[:category_property])
      flash[:success] = "保存成功"
      redirect_to :category_properties
    else
      render  :action=>:edit
    end
  end
  
  
  def destroy
    @category_property = CategoryProperty.find(params[:id])
    @category_property.destroy
    redirect_to :category_properties
  end


  def deletes
    @ids = params[:ids].split(",")
    CategoryProperty.destroy(@ids)
    redirect_to category_properties_path
  end
end
