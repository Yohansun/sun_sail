class SellersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

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

    respond_with @sellers
  end

  def show
    @seller = Seller.find params[:id]
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

    unless params[:seller_interface].blank?
      @seller.interface = params[:seller_interface]
    end

    if params[:parent_id].present? && params[:parent_id].to_i != 0 
      @seller.parent_id = params[:parent_id]
    end

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

    if params[:user_id].present?
      @seller.user_ids = case params[:method]
        when 'add'
          @seller.user_ids | [params[:user_id].to_i]
        when 'remove'
          @seller.user_ids - [params[:user_id].to_i]
        end
    end

    if params[:has_stock] == true
      @seller.has_stock = true
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
