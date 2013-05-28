# -*- encoding : utf-8 -*-
require "clockwork"
require './config/boot'
require './config/environment'

class UnusualStateMarker
  include Sidekiq::Worker
  sidekiq_options :queue => :unusual_state_marker

  def perform
    Account.all.each do |account|
      conditions = account.settings.auto_settings["unusual_conditions"]
      # 超过n天未付款
      if conditions['unusual_waitpay']
        trades = Trade.where(:created.lte => conditions['max_unpaid_days'].to_i.days.ago,
                             pay_time: nil,
                             status: "WAIT_BUYER_PAY")
        trades.each{|t| t.unusual_states.create(reason: "超过#{conditions['max_unpaid_days']}天未付款",
                                                key: "unpaid_in_#{conditions['max_unpaid_days']}_days",
                                                reporter: "系统预警",
                                                reporter_role: "magic_system",
                                                created_at: Time.now
                                                )}
      end

      # 超过n天未分流
      if conditions['unusual_dispatch']
        trades = Trade.where(:pay_time.lte => conditions['max_undispatched_days'].to_i.days.ago,
                             dispatched_at: nil,
                             seller_id: nil,
                             status: "WAIT_SELLER_SEND_GOODS")
        trades.each{|t| t.unusual_states.create(reason: "超过#{conditions['max_undispatched_days']}天未分流",
                                                key: "undispatched_in_#{conditions['max_undispatched_days']}_days",
                                                reporter: "系统预警",
                                                reporter_role: "magic_system",
                                                created_at: Time.now
                                                )}
      end

      # 超过n天未发货
      if conditions['unusual_deliver']
        trades = Trade.where(:dispatched_at.lte => conditions['max_undelivered_days'].to_i.days.ago,
                             consign_time: nil,
                             status: "WAIT_SELLER_SEND_GOODS")
        trades.each{|t| t.unusual_states.create(reason: "超过#{conditions['max_undelivered_days']}天未发货",
                                                key: "undelivered_in_#{conditions['max_undelivered_days']}_days",
                                                reporter: "系统预警",
                                                reporter_role: "magic_system",
                                                created_at: Time.now
                                                )}
      end

      # 超过n天未实际收货
      if conditions['unusual_receive']
        end_time = 1.week.ago
        start_time = end_time - 1.day
        trades = TaobaoTrade.between(delivered_at: start_time..end_time).where(status: 'TRADE_FINISHED', account_id: account.id)
        if trades.present?
          trades.each do |trade|
            response = TaobaoQuery.get({
              method: 'taobao.logistics.trace.search',
              fields: 'out_sid, company_name, status',
              tid: trade.tid,
              seller_nick: trade.try(:seller_nick)}, trade.try(:trade_source_id)
            )
            return unless response
            trace_response = response["logistics_trace_search_response"]
            #logistic_name = trace_response["company_name"]
            return unless trace_response["status"] == "对方已签收"
            trade.unusual_states.create(reason: "超过#{conditions["max_unreceived_days"]}天买家实际未收货",
                                        key: "unreceived_in_#{conditions["max_unreceived_days"]}_days",
                                        reporter: "系统预警",
                                        reporter_role: "magic_system",
                                        created_at: Time.now)
          end
        end
      end

      # 超过n天未处理异常
      if conditions['unusual_repair']
        trades = Trade.where(:unusual_states.elem_match =>{
                               :plan_repair_at => {"$lte" => (Time.now - conditions['max_unrepaired_days'].to_i.days)},
                               repaired_at: nil})
        trades.each{|t| t.unusual_states.create(reason: "超过#{conditions['max_unrepaired_days']}天未处理异常",
                                                key: "unrepaired_in_#{conditions['max_unrepaired_days']}_days",
                                                reporter: "系统预警",
                                                reporter_role: "magic_system",
                                                created_at: Time.now
                                                )}
      end

    end
  end
end

module Clockwork
  # Kick off a bunch of jobs early in the morning
  every 1.day, :at => '1:00 am' do
    UnusualStateMarker.new.perform
  end
end