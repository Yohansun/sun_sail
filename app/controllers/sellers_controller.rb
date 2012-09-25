# -*- encoding : utf-8 -*-
class SellersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @sellers = Seller
    if params[:parent_id]
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
    @children = (@seller.children).map(&:name)
    logger.debug(@children)
    respond_to do |format|
      format.json { render json: { :name => @children}}
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

  def user_list
    if params[:user_id].present?
      @user = User.where(id: params[:user_id], active: true, :seller_id => nil)
    else
      @user = User.where(active: true, :seller_id => nil)
    end
    respond_to do |f|
      f.js
    end
  end

  def change_stock_type
    @seller = Seller.find params[:id]
    @seller.update_attribute(:has_stock, !@seller.has_stock)
    redirect_to seller_stocks_path(@seller)
  end
end
