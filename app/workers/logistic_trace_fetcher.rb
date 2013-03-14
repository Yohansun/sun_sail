# -*- encoding : utf-8 -*-
require "clockwork"
require './config/boot'
require './config/environment'

class LogisticTraceFetcher
  include Sidekiq::Worker
  sidekiq_options :queue => :logistic_trace_fetcher

  def perform
    Account.all.each do |account|
      if account.settings.auto_settings["unusual_conditions"]['unusual_receive']
        end_time = 1.week.ago
        start_time = end_time - 1.day
        trades = TaobaoTrade.between(delivered_at: start_time..end_time).where(status: 'TRADE_FINISHED', account_id: account.id)
        if trades.present?
          days = account.settings.auto_settings["unusual_conditions"]["max_unreceived_days"]
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
            trade.unusual_states.create(reason: "超过#{days}天买家实际未收货", key: "unreceived_in_#{days}_days")
          end
        end
      end
    end
  end
end

module Clockwork
  # Kick off a bunch of jobs early in the morning
  every 1.day, :at => '1:00 am' do
    LogisticTraceFetcher.new.perform
  end
end