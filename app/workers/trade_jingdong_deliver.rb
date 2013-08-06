# -*- encoding : utf-8 -*-
class TradeJingdongDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_jingdong_deliver

  def perform(id)
    jingdong_logistics = {"YTO"=>1499, "ZTO"=>463, "OTHER"=>1274}
    trade = JingdongTrade.find(id)
    return unless trade

    tid = trade.tid
    account = trade.fetch_account
    query_conditions = account.jingdong_query_conditions

    errors = []

    response = JingdongQuery.get({method: '360buy.order.sop.outstorage',
                                  order_id: tid,
                                  logistics_id: jingdong_logistics[trade.logistic_code || "OTHER"],
                                  waybill: trade.logistic_waybill,
                                  trade_no: tid
                                  }, query_conditions
                                )

    if response['error_response'] && response['error_response']['zh_desc']
      errors << response['error_response']['zh_desc']
    end
    errors = errors.uniq

    if errors.blank?
      sop_stock_out_time = response['order_sop_outstorage_response']['modified']
      trade.update_attributes(sop_stock_out_time: sop_stock_out_time.to_time(:local))

      trade = TradeDecorator.decorate(trade)
      mobile = trade.receiver_mobile_phone
      shopname = account.settings.shopname_jingdong
      if trade.splitted?
        content = "亲您好，您的订单#{tid}已经发货，该订单将由地区发送，请注意查收。【#{shopname}】"
      else
        content = "亲您好，您的订单#{tid}已经发货，我们将尽快为您送达，请注意查收。【#{shopname}】"
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
      trade.status = 'WAIT_SELLER_SEND_GOODS'
      trade.save!
    end
  end
end