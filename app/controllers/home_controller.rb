class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    @logistics = current_account.logistics
    #FIX ME 
    @users = current_account.users
    @gift_products = current_account.products.where(good_type: 3)
  end

  def dashboard
  end
end