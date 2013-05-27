class HomeController < ApplicationController

  before_filter :check_account_wizard_status

  def index
    @logistics = current_account.logistics
    #FIX ME
    @users = current_account.users

    # NEED TO MODIFIED
    @gift_products = current_account.products.where(good_type: 3)
    if params[:ids].present?
	  name = []  
	  Trade.find(params[:ids]).each_with_index do |trade, index|  
		trade.orders.each do |td|
		  unless index == 0  
		    num = []  
		    name.each do |n|  
		      if n[:title] == td.title  
		         n[:num] += td.num  
		         num << n  
		      end  
		    end 
		    name << {title: td.title, num: td.num, category: td.sku_properties_name} if num .length == 0  
		  else  
		    name << {title: td.title, num: td.num, category: td.sku_properties_name}  
		  end  
		end  
	   end  
	   respond_to do |format|  
	     format.json { render json: name }  
	   end  
    end
  end

  def dashboard
  end
end