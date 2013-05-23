class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_account
  before_filter :authenticate_user!

  
  def authorize(ctrl = params[:controller], action = params[:action])
    current_user.current_account_id = session[:account_id]
    allowed = current_user.allowed_to?(ctrl,action)
    if allowed
      check_account_wizard_status && true
    else
      redirect_to root_path
    end
  end

  # check if account through wizard steps
  def check_account_wizard_status
    return true if current_account.nil? # if not login yet, skip check
    current_account.settings[:wizard_step] ||= :admin_init
    if current_account.settings[:wizard_step] != :finish &&
      (controller_name != "account_setups" || params[:id] != current_account.settings[:wizard_step].to_s)
      redirect_to account_setup_path(current_account.settings[:wizard_step])
    else
      true
    end
  end

  def current_account
    @current_account = Account.find_by_id(session[:account_id]) || Account.find_by_id(current_user.try(:accounts).try(:first).try(:id))
  end

end