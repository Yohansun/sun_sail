# -*- encoding : utf-8 -*-
class AreasController < ApplicationController
  skip_before_filter :authenticate_user!

  before_filter(:only => :index) do |controller|
    authenticate_user! && authorize unless controller.request.format.js?
  end

  caches_page :index, :if => Proc.new { |c| c.request.format.js? }

  def index
    @areas = case
      when params[:parent_id] 
        Area.where(parent_id: params[:parent_id])
      when params[:parent_name] 
        Area.where(parent_id: Area.find_by_name(params[:parent_name]).id)
      else
        Area.where(parent_id:nil)
      end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
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
    @areas = Area.where("id in (?)", ids).page(params[:page])
    render :index
  end
end
