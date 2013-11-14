# -*- encoding : utf-8 -*-
class SellersController < ApplicationController
  before_filter :authorize
  before_filter :check_module

  def index
    @sellers = current_account.sellers
    if params[:parent_id].present?
      @sellers = @sellers.where(parent_id: params[:parent_id])
      @parent = current_account.sellers.find_by_id params[:parent_id]
    else
      @sellers = @sellers.roots
    end
    if params[:info_type].present? || params[:info].present?
      @sellers = @sellers.where("BINARY #{params[:info_type]} like ? or #{params[:info_type]} = ?", "%#{params[:info].strip}%", params[:info].strip)
    end
    @sellers = @sellers.page(params[:page])
  end

  def export
    @sellers = current_account.sellers
    if params[:seller_ids].present?
      params[:seller_ids] = params[:seller_ids].split(',')
      params[:seller_ids] -= ['all_sellers']
      @sellers = @sellers.where(id: params[:seller_ids])
    end
    respond_to do |format|
      format.xls
    end
  end

  def import

  end

  def confirm_import_csv
    if params[:csv] && File.exists?(params[:csv])
      Seller.confirm_import_from_csv(current_account, params[:csv], false)
      Seller.confirm_import_from_csv(current_account, params[:csv], true)
    end
    redirect_to sellers_path
  end

  def import_csv
    if params[:file] && params[:file].tempfile
      @csv = "#{Rails.root}/public/#{Time.now.to_i}.csv"
      FileUtils.mv params[:file].tempfile, @csv
      begin
        @status_list = Seller.import_from_csv(current_account, @csv)
      rescue Exception => e
        Rails.logger.info e.inspect
        flash[:notice] = "上传文件有误请重新上传,只接受csv文件,可以先导出经销商报表,按照格式修改后导入"
        redirect_to :back
      end
    end
    @status_list ||= {}
    @changed_list  = @status_list.select {|k,v| v.present? }
  end

  def latest
    @sellers = current_account.sellers.where("created_at >= ? ", Time.now - 7.days).page(params[:page])
    render :index
  end

  def closed
    @sellers = current_account.sellers.where(active: false).page(params[:page])
    render :index
  end

  def new
    @seller = current_account.sellers.new
    @parent = current_account.sellers.find_by_id params[:parent_id]
  end

  def show
    @sellers = current_account.sellers.where(parent_id: params[:id])
  end

  def edit
    @seller = current_account.sellers.find_by_id params[:id]
  end

  def create
    @seller = current_account.sellers.new params[:seller]
    @seller.parent_id = params[:parent_id] if params[:parent_id]
    if @seller.save
      if params[:parent_id].present?
        redirect_to sellers_path(:parent_id => params[:parent_id])
      else
        redirect_to sellers_path
      end
    else
      render :new
    end
  end

  def update
    @seller = current_account.sellers.find(params[:id])
    if @seller.update_attributes(params[:seller])
      if !@seller.parent_id.blank?
        redirect_to sellers_path(:parent_id => @seller.parent_id)
      else
        redirect_to sellers_path
      end
    else
      render :edit
    end
  end

  def children
    @seller = current_account.sellers.find_by_id params[:id]
    @children = []
    @seller.children.each do |seller|
      @children << {
        id: seller.id,
        name: seller.fullname
      }
    end
    respond_to do |format|
      format.json { render json: @children }
    end
  end

  # TO BE REMOVED
  def status_update
    @seller = current_account.sellers.find_by_id params[:id]
    users = User.where(seller_id: params[:id])
    if @seller.active == true
      @seller.active =  false
      users.each do |user| user.lock_access! end
    else
      @seller.active = true
      users.each do |user| user.unlock_access! end
    end
    @seller.save!
    redirect_to sellers_path(:parent_id => @seller.parent_id)
  end

  def shutdown_seller
    @sellers = current_account.sellers.where(id: params[:seller_ids])
    @sellers.update_all(active: false)
    respond_to do |f|
      f.js
    end
  end

  def active_seller
    @sellers = current_account.sellers.where(id: params[:seller_ids])
    @sellers.update_all(active: true)
    respond_to do |f|
      f.js
    end
  end

  def seller_user
    @seller_user = User.where(seller_id: params[:seller_id])
    respond_to do |f|
      f.js
    end
  end

  def user_list
    users = current_account.users

    if params[:user_name].present?
      @user = users.where(["users.name like ?", "%#{params[:user_name].strip}%"])
    else
      @user = users.where(:seller_id => nil)
    end
    respond_to do |f|
      f.js
    end
  end

  def seller_user_list
    @flag = false
    user = User.find params[:u_id]
    user.seller_id = params[:s_id]
    if user.save
      @flag = true
    else
      @flag = false
    end
    @seller_user_list = User.where(seller_id: user.seller_id)
    respond_to do |f|
      f.js
    end
  end

  # TO BE REMOVED
  def change_stock_type
    @seller = current_account.sellers.find_by_id params[:id]
    @seller.update_attribute(:has_stock, !@seller.has_stock)
    if @seller.has_stock && !@seller.stock_opened_at
      @seller.update_attribute(:stock_opened_at, Time.now)
    end
    redirect_to seller_stocks_path(@seller)
  end

  def remove_seller_user
    user = User.find params[:u_id]
    user.seller_id = nil
    user.save
    respond_to do |f|
      f.js
    end
  end

  def seller_area
    @seller_areas = SellersArea.where(seller_id: params[:seller_id]).all
    respond_to do |f|
      f.js
    end
  end

  def create_seller_area
    seller_area = SellersArea.where(seller_id: params[:seller_id],area_id: params[:area_id])
    if !seller_area.present?
      seller_area = SellersArea.new
      seller_area.seller_id = params[:seller_id]
      seller_area.area_id = params[:area_id]
      seller_area.save
    end
    @seller_areas = SellersArea.where(seller_id: params[:seller_id]).all
    respond_to do |f|
      f.js
    end
  end

  def remove_seller_area
    if params[:seller_id] && params[:area_id]
      seller_area = SellersArea.select("id,area_id").where(seller_id: params[:seller_id],area_id: params[:area_id]).first
    end
    if params[:id]
      seller_area = SellersArea.find params[:id]
    end
    if seller_area.present?
      @area_id = seller_area.area_id
      SellersArea.destroy(seller_area)
    end
    respond_to do |f|
      f.js
    end
  end

  def info
    @seller = current_account.sellers.find_by_id params[:id]
  end

  def check_module
    redirect_to "/" and return if current_account.settings.enable_module_muti_sellers != 1
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end

  def area_sellers
    @state = Area.find_by_id(params[:area_id])
    unless @state
      if params[:area_id] && params[:area_id] == '0'
        @state = Area
      else
        @state = Area.find_by_name("北京")
      end
    end
    @leaves = @state.leaves
  end

end
