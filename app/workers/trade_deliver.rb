# -*- encoding : utf-8 -*-
class TradeDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_deliver, unique: true, unique_job_expiration: 60

  def perform(id)
    trade = Trade.find(id)
    return unless trade
    account = trade.fetch_account
    tid = trade.tid
    source_id = trade.trade_source_id

    errors = []

    if trade._type != "CustomTrade"
      if trade.is_merged?
        #返回合并订单各分订单物流信息
        trades = Trade.deleted.where(:_id.in => trade.merged_trade_ids)
        trades.update_all(logistic_waybill: trade.logistic_waybill,logistic_code: trade.logistic_code)
        trades.each_with_index{|merged_trade,index|

          if merged_trade.is_a? TaobaoTrade
            response = TaobaoQuery.get({
              method: 'taobao.logistics.offline.send',
              tid: merged_trade.tid,
              out_sid: trade.logistic_waybill,
              company_code: trade.logistic_code}, merged_trade.trade_source_id
            )
            if response['error_response'] &&  response['error_response']['sub_msg']
              errors << response['error_response']['sub_msg']
            end
          end
        }
      else
        response = TaobaoQuery.get({
          method: 'taobao.logistics.offline.send',
          tid: trade.tid,
          out_sid: trade.logistic_waybill,
          company_code: trade.logistic_code}, source_id
        )
        if response['error_response'] && response['error_response']['sub_msg']
          errors << response['error_response']['sub_msg']
        end
      end

      errors = errors.uniq

      if errors.blank?
        trade = TradeDecorator.decorate(trade)
        mobile = trade.receiver_mobile_phone
        shopname = trade.seller_nick
        if trade.splitted?
          content = "亲您好，您的订单#{tid}已经发货，该订单将由地区发送，请注意查收。【#{shopname}】"
        else
          if trade.is_merged?
            trade_tids = Trade.deleted.where(:_id.in => trade.merged_trade_ids).where(_type: "TaobaoTrade").map(&:tid).join(",")
            content = "亲您好，您的订单#{trade_tids}已经发货，我们将尽快为您送达，请注意查收。【#{shopname}】"
          else
            content = "亲您好，您的订单#{tid}已经发货，我们将尽快为您送达，请注意查收。【#{shopname}】"
          end
        end

        notify_kind = "after_send_goods"
        if content && mobile
          SmsNotifier.perform_async(content, mobile, tid ,notify_kind)
        end

        unless account.settings.enable_module_third_party_stock == 1
          trade.stock_out_bill.decrease_actual
        end
      else
        Notifier.deliver_errors(id, errors, trade.account_id).deliver
        errors.each do |error_reason|
          trade.unusual_states.build(reason: "发货异常: #{error_reason}", key: 'other_unusual_state', created_at: Time.now)
        end
        trade.save
        trade.update_attributes!(status: 'WAIT_SELLER_SEND_GOODS')
      end
    else
      unless account.settings.enable_module_third_party_stock == 1
        trade.stock_out_bill.decrease_actual
      end
    end
  end
end