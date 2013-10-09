# -*- encoding : utf-8 -*-
class AreasController < ApplicationController
  skip_before_filter :authenticate_user!
  layout 'management'

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

	def export
    @areas = Area
    if params[:area_ids].present?
      params[:area_ids] = params[:area_ids].split(',')
      params[:area_ids] -= ['all_areas']
      @selected_areas = @areas.where(id: params[:area_ids])
    end
    respond_to do |format|
      format.xls
    end
  end

   def import

  end

  def confirm_import_csv
    if params[:csv] && File.exists?(params[:csv])
      Area.confirm_import_from_csv(current_account, params[:csv], false)
      Area.confirm_import_from_csv(current_account, params[:csv], true)
    end
    redirect_to areas_path
  end

  def import_csv
    if params[:file] && params[:file].tempfile
      @csv = "#{Rails.root}/public/#{Time.now.to_i}.csv"
      FileUtils.mv params[:file].tempfile, @csv
      begin
        @status_list = Area.import_from_csv(current_account, @csv)
      rescue Exception => e
        Rails.logger.info e.inspect
        flash[:notice] = "上传文件有误请重新上传,只接受csv文件,可以先导出地区经销商报表,按照格式修改后导入"
        redirect_to :back
      end
    end
    @status_list ||= {}
    @changed_list  = @status_list.select {|k,v| v.present? }
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

  def sellers
    @state = Area.find_by_id(params[:area_id])
    unless @state
      if params[:area_id]
        if params[:area_id] == '0'
          @state = Area
        end
      else
        @state = Area.find_by_name("北京")
      end
    end
    @leaves = @state.leaves
  end
end
