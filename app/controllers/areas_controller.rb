# -*- encoding : utf-8 -*-
class AreasController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!

  def index
    unless params[:parent_id]
      params[:parent_id] = 1
    end

    @areas = Area.where(parent_id: params[:parent_id])
    respond_with @areas
  end

	#TODO 导出表中其他表的数据依赖关系不满足,依赖建立后释放模板
	def export
    @areas = Area.where "parent_id IS NULL"
  end

  def update
    @area = Area.find params[:id]
    if @area.update_attributes params[:area]
      redirect_to areas_url
    else
      render :edit
    end
  end

  def create
    @area = Area.new params[:area]
    if @area.save
      redirect_to areas_url
    else
      render :new
    end
  end

  def autocomplete
  	areas = Area.select("name,id").where("name like ?", "%#{params[:q]}%")
  	respond_to do |format|
  		format.json {render :json => areas}
  	end
  end

  def area_search
    ids = params[:q].split(",") || ""
    @areas = Area.where("id in (?)", ids).paginate(:page => params[:page], :per_page => 50)
    render :index
  end
end