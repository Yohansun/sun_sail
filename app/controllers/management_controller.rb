class ManagementController < ActionController::Base
  before_filter :alert_count

  def alert_count
    @alert_counts = 0
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