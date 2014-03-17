#encoding: utf-8
class TradeYihaodianDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_yihaodian_deliver, unique: true, unique_job_expiration: 120

  def perform(id)
    trade       = YihaodianTrade.where(_id: id).first rescue raise("没有找到一号店订单号为#{id}")
    trade       = TradeDecorator.decorate(trade)
    mobile      = trade.receiver_mobile_phone
    account     = trade.fetch_account
    shopname    = trade.seller_nick
    content     = "亲您好，您的订单#{trade.tid}已经发货，我们将尽快为您送达，请注意查收。【#{shopname}】"
    notify_kind = "after_send_goods"

    if trade.shipment == true
      if account.can_send_sms('deliver_notify')
        result = account.can_auto_notify_right_now
        SmsNotifier.perform_in(result, content, mobile, trade.tid ,notify_kind) if mobile.present?
      end
      trade.stock_out_bill.confirm_stock if not account.enabled_third_party_stock?
      trade.status = 'ORDER_CAN_OUT_OF_WH'
    else
      trade.unusual_states.build(reason:        "发货异常",
                                 key:           "other_unusual_state",
                                 reporter:      "系统预警",
                                 reporter_role: "magic_system",
                                 created_at:    Time.now)
    end

    trade.save! rescue BacktraceMailer.background_exception_notification($!)
  end
end