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
end
