class SellersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def index
    if params[:parent_id]
      @sellers = Seller.where(parent_id: params[:parent_id])
    else
      @sellers = Seller.roots
    end

    respond_with @sellers
  end

  def show
    @seller = Seller.where(id: params[:id]).first
    respond_with @seller
  end

  def create
    @seller = Seller.create
    unless params[:seller_name].blank?
      @seller.name = params[:seller_name]
    end

    unless params[:seller_fullname].blank?
      @seller.fullname = params[:seller_fullname]
    end

    unless params[:seller_mobile].blank?
      @seller.mobile = params[:seller_mobile]
    end

    unless params[:seller_address].blank?
      @seller.address = params[:seller_address]
    end

    unless params[:seller_email].blank?
      @seller.email = params[:seller_email]
    end

    @seller.interface = params[:seller_interface]

    @seller.save

    respond_with @seller
  end

  def update
    @seller = Seller.where(id: params[:id]).first

    unless params[:seller_name].blank?
      @seller.name = params[:seller_name]
    end

    unless params[:seller_fullname].blank?
      @seller.fullname = params[:seller_fullname]
    end

    unless params[:seller_mobile].blank?
      @seller.mobile = params[:seller_mobile]
    end

    unless params[:seller_address].blank?
      @seller.address = params[:seller_address]
    end

    unless params[:seller_email].blank?
      @seller.email = params[:seller_email]
    end

    unless params[:seller_performance_score].blank?
      @seller.performance_score = params[:seller_performance_score]
    end
    
    unless params[:seller_interface].blank?
      @seller.interface = params[:seller_interface]
    end

    @seller.active = !@seller.active

    @seller.save!

    respond_with @seller
  end


  def children
    @seller = Seller.find params[:id]
    @children = @seller.children
  end
end
