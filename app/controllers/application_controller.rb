class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_account
  before_filter :authenticate_user!
  before_filter :alert_count
  before_filter :get_trades

  def get_trades
    if current_user.allow_read?(:trades,:seller) && current_user.seller
      @today_trades    = Trade.where(account_id: current_account.id, seller_id: current_user.seller.id, has_unusual_state: true, :unusual_states.elem_match => {created_at: {"$gte" => Time.now.beginning_of_day, "$lt" => Time.now.end_of_day}})
      @tomorrow_trades = Trade.where(account_id: current_account.id, seller_id: current_user.seller.id, has_unusual_state: true, :unusual_states.elem_match => {plan_repair_at: {"$gte" => Time.now.tomorrow.beginning_of_day, "$lt" => Time.now.tomorrow.end_of_day}})
    else
      @today_trades    = Trade.where(account_id: current_account.id, has_unusual_state: true, :unusual_states.elem_match => {created_at: {"$gte" => Time.now.beginning_of_day, "$lt" => Time.now.end_of_day}})
      @tomorrow_trades = Trade.where(account_id: current_account.id, has_unusual_state: true, :unusual_states.elem_match => {plan_repair_at: {"$gte" => Time.now.tomorrow.beginning_of_day, "$lt" => Time.now.tomorrow.end_of_day}})
    end
  end

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

  def alert_count
    @alert_counts = 0
    # return false if current_user.nil?
    # if current_user.allow_read?(:trades,:seller) && current_user.seller
    #   trades = Trade.where(account_id: current_account.id, seller_id: current_user.seller.id)
    # else
    #   trades = Trade.where(account_id: current_account.id)
    # end
    # @alert_counts = trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "buyer_delay_deliver", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count +
    #                 trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "seller_ignore_deliver", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count +
    #                 trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "seller_lack_product", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count +
    #                 trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "seller_lack_color", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count +
    #                 trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "buyer_demand_refund", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count +
    #                 trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "buyer_demand_return_product", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count +
    #                 trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "other_unusual_state", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count
    # if current_account.settings.auto_settings["auto_mark_unusual_trade"]
    #   unusual_auto_settings = current_account.settings.auto_settings["unusual_conditions"]
    #   if unusual_auto_settings['unusual_waitpay']
    #     @alert_counts += trades.where(:unusual_states.elem_match => {key: "unpaid_in_#{unusual_auto_settings['max_unpaid_days']}_days", :repaired_at => nil}).or({"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}).count
    #   end
    #   if unusual_auto_settings['unusual_deliver']
    #     @alert_counts += trades.where(:unusual_states.elem_match => {key: "undelivered_in_#{unusual_auto_settings['max_undelivered_days']}_days", :repaired_at => nil}).or({"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}).count
    #   end
    #   if unusual_auto_settings['unusual_dispatch']
    #     @alert_counts += trades.where(:unusual_states.elem_match => {key: "undispatched_in_#{unusual_auto_settings['max_undispatched_days']}_days", :repaired_at => nil}).or({"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}).count
    #   end
    #   if unusual_auto_settings['unusual_receive']
    #     @alert_counts += trades.where("$and" => [{"unusual_states" => {"$elemMatch" => {key: "unreceived_in_#{unusual_auto_settings['max_unreceived_days']}_days", repaired_at: nil}}}, {"$or" => [{"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}]}]).count
    #   end
    #   if unusual_auto_settings['unusual_repair']
    #     @alert_counts += trades.where(:unusual_states.elem_match => {key: "unrepaired_in_#{unusual_auto_settings['max_unrepaired_days']}_days", :repaired_at => nil}).or({"has_buyer_message" => {"$ne" => true}}, {"buyer_message"=> {"$ne" => nil}}).count
    #   end
    # end
  end

end