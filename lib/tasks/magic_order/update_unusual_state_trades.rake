#encoding: utf-8
namespace :magic_order do
  desc "更正被错误标注异常的订单"
  task :update_unusual_state_trades => :environment do
    Trade.where(:updated_at.gt => "2014-02-17 00:00:00 +0800".to_time,:updated_at.lt => "2014-02-18 00:00:00 +0800".to_time,has_refund_orders: true).each do |trade|
      if trade.orders.all? {|order| order.refund_status == "NO_REFUND"}
        trade.has_refund_orders = false
        trade.unusual_states.each {|unusual_state| unusual_state.reason == "买家要求退款" && unusual_state.destroy }
        trade.save!
      end
    end
  end
end