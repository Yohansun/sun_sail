class HomeController < ApplicationController

  def index
    @logistics = current_account.logistics
    #FIX ME 
    @users = current_account.users

    # NEED TO MODIFIED
    @gift_products = current_account.products.where(good_type: 3)
  end

  def dashboard
  end
end