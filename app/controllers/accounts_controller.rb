# encoding: utf-8
class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_account
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

  def current_account
    @current_account = Account.find_by_id(session[:account_id]) || Account.find_by_id(current_user.try(:accounts).try(:first).try(:id))
  end

end