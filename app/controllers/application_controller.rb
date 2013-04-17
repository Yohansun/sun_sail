class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_account

  
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = current_user.allowed_to?(ctrl,action)
    if allowed
      true
    else
      deny_access
    end
  end

  def admin_only!
    unless user_signed_in? && authorize
      redirect_to root_path
      return false
    end
  end
  
  def deny_access
    redirect_to root_path
  end

  def current_account
    @current_account = Account.find_by_id(session[:account_id]) || Account.find_by_id(current_user.try(:accounts).try(:first).try(:id))
  end

end