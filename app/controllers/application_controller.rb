class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_account
  before_filter :authenticate_user!
  before_filter :get_trades

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
    @current_account ||= (session[:account_id] && Account.find(session[:account_id])) || (current_user && current_user.accounts.first)
  end

  def get_trades
    if current_user
      if current_user.allow_read?(:trades,:seller) && current_user.seller
        @today_trades    = Trade.where(account_id: current_account.id, seller_id: current_user.seller.id, has_unusual_state: true, :unusual_states.elem_match => {created_at: {"$gte" => Time.now.beginning_of_day, "$lt" => Time.now.end_of_day}})
        @tomorrow_trades = Trade.where(account_id: current_account.id, seller_id: current_user.seller.id, has_unusual_state: true, :unusual_states.elem_match => {plan_repair_at: {"$gte" => Time.now.tomorrow.beginning_of_day, "$lt" => Time.now.tomorrow.end_of_day}})
      else
        @today_trades    = Trade.where(account_id: current_account.id, has_unusual_state: true, :unusual_states.elem_match => {created_at: {"$gte" => Time.now.beginning_of_day, "$lt" => Time.now.end_of_day}})
        @tomorrow_trades = Trade.where(account_id: current_account.id, has_unusual_state: true, :unusual_states.elem_match => {plan_repair_at: {"$gte" => Time.now.tomorrow.beginning_of_day, "$lt" => Time.now.tomorrow.end_of_day}})
      end
    end
  end

end