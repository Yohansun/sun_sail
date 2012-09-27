# -*- encoding : utf-8 -*-
class SellersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @sellers = Seller
    if params[:parent_id].present?
      @sellers = @sellers.where(parent_id: params[:parent_id])
    else
      @sellers = @sellers.roots
    end
    @sellers = @sellers.page(params[:page])

  end

  def search
    flag = false
    if params[:keyword].present?
      if params[:where_name] == "id"
        @sellers = Seller.where(id: params[:keyword].strip)
      end
      if params[:where_name] == "fullname"
        @sellers = Seller.where(["fullname like ?", "%#{params[:keyword].strip}%"])
      end
      if params[:where_name] == "name"
        @sellers = Seller.where(["name like ?", "%#{params[:keyword].strip}%"])
      end
      if params[:where_name] == "address"
        @sellers = Seller.where(["address like ?", "%#{params[:keyword].strip}%"])
      end
      @sellers = @sellers.page(params[:page])
      flag = true
    else
      flag = false
    end
    if flag
      render :index
    else
      redirect_to sellers_path
    end
  end

  def new
    @seller = Seller.new
  end

  def show
    @sellers = Seller.where(parent_id: params[:id])
  end

  def edit
    @seller = Seller.find params[:id]
  end

  def create
    @seller = Seller.new params[:seller]
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
    @seller = Seller.find(params[:id])
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
    @seller = Seller.find params[:id]
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
    @seller = Seller.find params[:id]
    if @seller.active == true
      @seller.active =  false
    else
      @seller.active = true
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
    @seller = Seller.find params[:id]
    @seller.update_attribute(:has_stock, !@seller.has_stock)
    redirect_to seller_stocks_path(@seller)
  end

  def remove_seller_user
    seller_id = ""
    user = User.find params[:u_id]
    seller_id = user.seller_id
    user.seller_id = nil
    user.save 
    @seller_user = User.where(seller_id: seller_id)
    render :seller_user
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
end
