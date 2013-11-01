#encoding: utf-8
class TradeYihaodianDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_yihaodian_deliver, unique: true, unique_job_expiration: 120

  def perform(id)
    trade = YihaodianTrade.where(_id: id).first rescue raise("没有找到一号店订单号为#{id}")

    trade = TradeDecorator.decorate(trade)
    mobile = trade.receiver_mobile_phone
    account = trade.fetch_account
    shopname = trade.seller_nick
    content = "亲您好，您的订单#{trade.tid}已经发货，%s，请注意查收。【#{shopname}】" % (trade.splitted? ? "该订单将由地区发送" : "我们将尽快为您送达")

    notify_kind = "after_send_goods"

    if trade.shipment == true
      SmsNotifier.perform_async(content, mobile, trade.tid ,notify_kind)  if mobile.present?
      trade.stock_out_bill.decrease_actual                                if account.settings.enable_module_third_party_stock != 1
      trade.status = 'ORDER_CAN_OUT_OF_WH'
    else
      trade.unusual_states.build(reason: "发货异常",
                                 key: 'other_unusual_state',
                                 reporter: "系统预警",
                                 reporter_role: "magic_system",
                                 created_at: Time.now)
    end

    trade.save! rescue BacktraceMailer.background_exception_notification($!)
  end
end