# -*- encoding : utf-8 -*-
class UnusualTradesNotifier
  include Sidekiq::Worker
  sidekiq_options :queue => :unusual_trades_notifier, unique: true, unique_job_expiration: 120,  unique_unlock_order: :before_yield

  def perform()
    Account.find_each do |account|
      if account.settings.auto_settings['auto_notify'] && account.can_auto_notify_right_now
        conditions = account.settings.auto_settings["notify_conditions"]
        notify_users = account.users.where(:id => conditions['notify_users'].collect{|id| id.to_i})

        #已付款订单n小时内没有分派
        if conditions['dispatch_delay']
          check_time = conditions['max_dispatch_delay_hours'].to_i.hours.ago
          trades = account.trades.between(created: (Time.now - 1.week)..Time.now)
          trades = trades.where(
            :pay_time.lte => check_time,
            dispatched_at: nil,
            seller_id: nil,
            is_notified: false,
            :status.in => Trade::StatusHash['paid_not_deliver_array'],
          )
          if trades.present?
            tids = trades.map(&:tid)
            message = "您好，您的订单#{tids}在#{check_time}小时内没有分派"
            if conditions['send_sms']
              Sms.new(account, message, notify_users.map(&:phone).join(",")).transmit
            end
            if conditions['send_email']
              Notifier.unusual_trade_notify(notify_users.map(&:email).join(","), message, account.id)
            end
            trades.update_all(is_notified: true)
          end
        end


        #已分派订单n小时内没有发货
        if conditions['deliver_delay']
          check_time = conditions['max_deliver_delay_hours'].to_i.hours.ago
          trades = account.trades.between(created: (Time.now - 1.week)..Time.now)
          trades = trades.where(
            :dispatched_at.lte => check_time,
            consign_time: nil,
            :status.in => Trade::StatusHash['paid_not_deliver_array'],
            is_notified: false
          )
          if trades.present?
            tids = trades.map(&:tid)
            message = "您好，您的订单#{tids}在#{check_time}小时内没有发货"
            if conditions['send_sms']
              Sms.new(account, message, notify_users.map(&:phone).join(",")).transmit
            end
            if conditions['send_email']
              Notifier.unusual_trade_notify(notify_users.map(&:email).join(","), message, account.id)
            end
            trades.update_all(is_notified: true)
          end
        end


        #异常订单到预处理时间后再延后n小时后买家没有确认收货
        if conditions['fixed_unreceived']
          check_time = conditions['max_fixed_unreceived_hours'].to_i.hours.ago
          trades = account.trades.between(created: (Time.now - 1.week)..Time.now)
          trades = trades.where(
            :unusual_states.elem_match =>{:plan_repair_at => {"$lte" => check_time}},
            confirm_receive_at: nil,
            is_notified: false
          )
          if trades.present?
            tids = trades.map(&:tid)
            message = "您好，您的异常订单#{tids}在订单预处理时间再延后#{check_time}小时后买家没有确认收货"
            if conditions['send_sms']
              Sms.new(account, message, notify_users.map(&:phone).join(",")).transmit
            end
            if conditions['send_email']
              Notifier.unusual_trade_notify(notify_users.map(&:email).join(","), message, account.id)
            end
            trades.update_all(is_notified: true)
          end
        end


        #延迟发货的异常订单，在预处理时间到期前n天内通知
        if conditions['delay_again']
          check_time = conditions['max_delay_again_hours'].to_i.hours.ago
          trades = account.trades.between(created: (Time.now - 1.week)..Time.now)
          trades = trades.where(
            :unusual_states.elem_match =>{:plan_repair_at => {"$gte" => check_time}, reason: "买家延迟发货", repaired_at: nil},
            is_notified: false
          )
          if trades.present?
            tids = trades.map(&:tid)
            message = "您好，您延迟发货的异常订单#{tids}预处理时间即将到期"
            if conditions['send_sms']
              Sms.new(account, message, notify_users.map(&:phone).join(",")).transmit
            end
            if conditions['send_email']
              Notifier.unusual_trade_notify(notify_users.map(&:email).join(","), message, account.id)
            end
            trades.update_all(is_notified: true)
          end
        end


        #订单由于地域没有绑定经销商导致不能自动分派
        if conditions['dispatch_stuck']
          trades = account.trades.between(created: (Time.now - 3.day)..Time.now)
          trades = trades.where(
            dispatched_at: nil,
            seller_id: nil,
            is_notified: false,
            :status.in => Trade::StatusHash['paid_not_deliver_array']
          )
          if trades.present?
            tids = trades.collect{|trade| (SellerMatcher.match_trade_seller(trade.id, trade.default_area) || trade.default_seller).present? ? trade.tid : nil}.compact
          end
          if tids.present?
            message = "您好，您的订单#{tids}由于地域没有绑定经销商导致不能自动分派"
            if conditions['send_sms']
              Sms.new(account, message, notify_users.map(&:phone).join(",")).transmit
            end
            if conditions['send_email']
              Notifier.unusual_trade_notify(notify_users.map(&:email).join(","), message, account.id)
            end
            trades.where(:tid.in => tids).update_all(is_notified: true)
          end
        end

        #订单商品分类为XX
        if conditions['special_category']
          trades = account.trades.between(created: (Time.now - 4.hour)..Time.now).where(is_notified: false)
          if trades.present?
            special_categories = account.categories.where("id in (?)", conditions['categories'])
            tids = trades.each do |trade|
              trade.orders.each do |order|
                if (order.categories & special_categories).present?
                  return tid
                end
              end
            end
            if tids.present?
              message = "您好，您的订单#{tids}包含有特殊分类的商品"
              if conditions['send_sms']
                Sms.new(account, message, notify_users.map(&:phone).join(",")).transmit
              end
              if conditions['send_email']
                Notifier.unusual_trade_notify(notify_users.map(&:email).join(","), message, account.id)
              end
              trades.where(:tid.in => tids).update_all(is_notified: true)
            end
          end
        end
      end
    end
    UnusualTradesNotifier.perform_in(3.hour)
  end
end