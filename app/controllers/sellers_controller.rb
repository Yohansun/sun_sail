# -*- encoding : utf-8 -*-
class SellersController < ApplicationController
  before_filter :authorize

  def index
    @sellers = current_account.sellers
    if params[:parent_id].present?
      @sellers = @sellers.where(parent_id: params[:parent_id])
    else
      @sellers = @sellers.roots
    end
    @sellers = @sellers.page(params[:page])

  end

  def search
    if  params[:where_name] && params[:keyword].present?
      @sellers  = current_account.sellers.where(["#{params[:where_name]} like ?", "%#{params[:keyword].strip}%"])
      @sellers  = @sellers.page(params[:page])
    end
    if @sellers 
      render :index
    else
      redirect_to sellers_path
    end   
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
  end

  def show
    @sellers = current_account.sellers.where(parent_id: params[:id])
  end

  def edit
    @seller = current_account.sellers.find params[:id]
  end

  def create
    @seller = current_account.sellers.new params[:seller]
    @seller.parent_id = params[:p_id] if params[:p_id]
    if @seller.save
      if params[:p_id].present?
        redirect_to sellers_path(:parent_id => params[:p_id])
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
    @seller = current_account.sellers.find params[:id]
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

  def status_update
    @seller = current_account.sellers.find params[:id]
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

  def seller_user
    @seller_user = User.where(seller_id: params[:seller_id])
    respond_to do |f|
      f.js
    end
  end

  def user_list
    if params[:user_name].present?
      @user = User.where(["seller_id is null and name like ?", "%#{params[:user_name].strip}%"])
    else
      @user = User.where(:seller_id => nil)
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

  def change_stock_type
    @seller = current_account.sellers.find params[:id]
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
    @seller = current_account.sellers.find params[:id]
  end

end
