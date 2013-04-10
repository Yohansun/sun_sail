# -*- encoding : utf-8 -*-
class UnusualStateMarker
  include Sidekiq::Worker
  sidekiq_options :queue => :unusual_state_marker

  def perform(id, version)
    account = Account.find(id)
    conditions = account.settings.auto_settings["unusual_conditions"]
    if account.settings.auto_settings['auto_mark_unusual_trade'] && version == conditions['frequency_version']
      time_gap = 7 #默认抓取一周的订单比对异常

      # 超过n天未付款
      if conditions['unusual_waitpay']
        check_time = conditions['max_unpaid_days'].to_i.days.ago
        trades = Trade.between(created: (check_time - time_gap.hours)..check_time)
        trades = trades.where(:created.lte => check_time,
                              pay_time: nil,
                              status: "WAIT_BUYER_PAY",
                              account_id: account.id)
        reason = "超过#{conditions['max_unpaid_days']}天未付款"
        key = "unpaid_in_#{conditions['max_unpaid_days']}_days"
        trades.each do |trade|
          if trade.unusual_states.where(key: key).count == 0
            trade.unusual_states.create(reason: reason,
                                        key: key,
                                        reporter: "系统预警",
                                        reporter_role: "magic_system",
                                        created_at: Time.now
                                        )
          end
        end
      end

      # 超过n天未分流
      if conditions['unusual_dispatch']
        check_time = conditions['max_undispatched_days'].to_i.days.ago
        trades = Trade.between(created: (check_time - time_gap.hours)..check_time)
        trades = trades.where(:pay_time.lte => check_time,
                             dispatched_at: nil,
                             seller_id: nil,
                             status: "WAIT_SELLER_SEND_GOODS",
                             account_id: account.id)
        reason = "超过#{conditions['max_undispatched_days']}天未分流"
        key = "undispatched_in_#{conditions['max_undispatched_days']}_days"
        trades.each do |trade|
          if trade.unusual_states.where(key: key).count == 0
            trade.unusual_states.create(reason: reason,
                                        key: key,
                                        reporter: "系统预警",
                                        reporter_role: "magic_system",
                                        created_at: Time.now
                                        )
          end
        end
      end

      # 超过n天未发货
      if conditions['unusual_deliver']
        check_time = conditions['max_undelivered_days'].to_i.days.ago
        trades = Trade.between(created: (check_time - time_gap.hours)..check_time)
        trades = trades.where(:dispatched_at.lte => check_time,
                             consign_time: nil,
                             status: "WAIT_SELLER_SEND_GOODS",
                             account_id: account.id)
        reason = "超过#{conditions['max_undelivered_days']}天未发货"
        key = "undelivered_in_#{conditions['max_undelivered_days']}_days"
        trades.each do |trade|
          if trade.unusual_states.where(key: key).count == 0
            trade.unusual_states.create(reason: reason,
                                        key: key,
                                        reporter: "系统预警",
                                        reporter_role: "magic_system",
                                        created_at: Time.now
                                        )
          end
        end
      end

      # 超过n天未实际收货
      if conditions['unusual_receive']
        check_time = conditions['max_unreceived_days'].to_i.days.ago
        trades = Trade.between(created: (check_time - time_gap.hours)..check_time)
        trades = trades.where(status: 'TRADE_FINISHED', account_id: account.id)
        reason = "超过#{conditions["max_unreceived_days"]}天买家实际未收货"
        key = "unreceived_in_#{conditions["max_unreceived_days"]}_days"
        trades.each do |trade|
          response = TaobaoQuery.get({
            method: 'taobao.logistics.trace.search',
            fields: 'out_sid, company_name, status',
            tid: trade.tid,
            seller_nick: trade.try(:seller_nick)}, trade.try(:trade_source_id)
          )
          unless response && response["logistics_trace_search_response"] && response["logistics_trace_search_response"]["status"] == "对方已签收"
            if trade.unusual_states.where(key: key).count == 0
              trade.unusual_states.create(reason: reason,
                                          key: key,
                                          reporter: "系统预警",
                                          reporter_role: "magic_system",
                                          created_at: Time.now
                                          )
            end
          end
        end
      end

      # 超过n天未处理异常
      if conditions['unusual_repair']
        check_time = conditions['max_unrepaired_days'].to_i.days.ago
        trades = Trade.between(created: (check_time - time_gap.hours)..check_time)
        trades = trades.where(:unusual_states.elem_match =>{
                              :plan_repair_at => {"$lte" => check_time},
                              repaired_at: nil})
        reason = "超过#{conditions['max_unrepaired_days']}天未处理异常"
        key = "unrepaired_in_#{conditions['max_unrepaired_days']}_days"
        trades.each do |trade|
          if trade.unusual_states.where(key: key).count == 0
            trade.unusual_states.create(reason: reason,
                                        key: key,
                                        reporter: "系统预警",
                                        reporter_role: "magic_system",
                                        created_at: Time.now
                                        )
          end
        end
      end
    end
    # 如果标注异常时间间隔改变，关闭队列，在controller中会重开新队列
    if version == conditions['frequency_version']
      UnusualStateMarker.perform_in(account.settings.auto_settings['preprocess_silent_gap'].to_i.hours, account.id, version)
    end
  end
end