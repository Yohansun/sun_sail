# -*- encoding : utf-8 -*-
class TradeJingdongDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_jingdong_deliver, unique: true, unique_job_expiration: 120

  def perform(id)
    trade = JingdongTrade.where(_id: id).first or return
    tid = trade.tid.split('-')[0]
    account = trade.fetch_account
    trade_source = account.jingdong_sources.first
    query_conditions = trade_source.jingdong_query_conditions

    errors = []

    response = if trade.parent_type_split_trade? && trade.parent.try(:sop_stock_out_time).present?
      {"order_sop_outstorage_response" => {"modified" => Time.now.to_s}}
    else
      JingdongQuery.get({method: '360buy.order.sop.outstorage',order_id: tid,logistics_id: trade.service_logistic_id,waybill: trade.logistic_waybill,trade_no: tid}, query_conditions)
    end

    if response['error_response'] && response['error_response']['zh_desc']
      errors << response['error_response']['zh_desc']
    end
    errors = errors.uniq

    if errors.blank?
      sop_stock_out_time = response['order_sop_outstorage_response']['modified']
      trade.update_attributes(sop_stock_out_time: sop_stock_out_time.to_time(:local))

      if trade.parent_type_split_trade? && trade.parent.try(:sop_stock_out_time).present?
        Trade.unscoped.where(id: trade.parent_id).update_all(sop_stock_out_time: trade.sop_stock_out_time)
      end

      if account.can_send_sms('deliver_notify')
        result      = account.can_auto_notify_right_now
        trade       = TradeDecorator.decorate(trade)
        mobile      = trade.receiver_mobile_phone
        shopname    = trade.seller_nick
        content     = "亲您好，您的订单#{tid}已经发货，我们将尽快为您送达，请注意查收。【#{shopname}】"
        notify_kind = "after_send_goods"
        SmsNotifier.perform_in(result, content, mobile, tid ,notify_kind) if (content && mobile)
      end

      trade.stock_out_bill.confirm_stock if not account.enabled_third_party_stock?
    else
      Notifier.deliver_errors(id, errors, trade.account_id).deliver
      errors.each do |error_reason|
        trade.unusual_states.build(reason: "发货异常: #{error_reason}", key: 'other_unusual_state', created_at: Time.now)
      end
      trade.status = 'WAIT_SELLER_SEND_GOODS'
      trade.save!
    end
  end
end