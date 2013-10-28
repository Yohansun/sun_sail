# encoding: utf-8
class AccountsController < ApplicationController
  before_filter :authenticate_user!
  def index
  	@account = Account.new
  end

  def create
  	current_account.update_attributes!(:seller_name => params[:seller_name], :name =>
  		params[:name], :phone => params[:phone], 
  		:deliver_bill_info => params[:deliver_bill_info],
  		:address => params[:address], :website => params[:website],
      :point_out => params[:point_out]
  		)
    render :index
  end
end