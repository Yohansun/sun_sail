class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_account
  before_filter :authenticate_user!

  
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = current_user.allowed_to?(ctrl,action)
    if allowed
      true
    else
      redirect_to root_path
    end
  end

  def current_account
    @current_account = Account.find_by_id(session[:account_id]) || Account.find_by_id(current_user.try(:accounts).try(:first).try(:id))
  end

end