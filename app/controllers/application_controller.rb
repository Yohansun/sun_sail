class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_account

  def admin_only!
    unless user_signed_in? && current_user.has_role?(:admin)
      redirect_to root_path
      return false
    end
  end

  def current_account
    @current_account ||= Account.find_by_id(session[:account_id]) if session[:account_id]
  end

end
