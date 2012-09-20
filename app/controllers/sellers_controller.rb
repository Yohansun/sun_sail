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

    if params[:key].present? && params[:value].present?
      @sellers = @sellers.where(params[:key].to_sym => params[:value])
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
      redirect_to sellers_path(:parent_id => params[:p_id])
    else
      render :new
    end
  end

  def update
    @seller = Seller.find(params[:id])
    if @seller.update_attributes(params[:seller])
      redirect_to sellers_path(:parent_id => @seller.parent_id)
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
end
