# -*- encoding : utf-8 -*-
class TradeDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :trade_deliver, unique: true, unique_job_expiration: 120

  def perform(id)
    trade = Trade.where(_id: id).first or return
    trade.stock_out_bill.confirm_stock if not trade.fetch_account.enabled_third_party_stock?
    deliver(trade)
  end

  def deliver_failed(ary)
    trade,reason= Array.wrap(ary)
    trade.status =  'WAIT_SELLER_SEND_GOODS'
    trade.unusual_states.build(reason: "发货异常:#{reason}", key: 'other_unusual_state', created_at: Time.now)
    trade.save
  end

  def deliver(trade)
    return if trade._type == "CustomTrade"

    deliver_failed(catch(:deliver_error) {
      trade.is_merged? ? merged_deliver(trade) : trade_deliver(trade)
      send_sms(trade)
      return
      })
  end

  def merged_deliver(trade)
    #返回合并订单各分订单物流信息
    trades = Trade.deleted.where(:_id.in => trade.merged_trade_ids)
    trades.update_all(logistic_waybill: trade.logistic_waybill,logistic_code: trade.logistic_code)
    trades.where(_type: "TaobaoTrade").each {|trade| handle_response(trade)}
  end

  def trade_deliver(trade); handle_response(trade); end

  def send_sms(trade)
    trade = TradeDecorator.decorate(trade)
    mobile = trade.receiver_mobile_phone
    shopname = trade.seller_nick
    content = if trade.splitted?
       "亲您好，您的订单#{trade.tid}已经发货，该订单将由地区发送，请注意查收。【#{shopname}】"
    else
      "亲您好，您的订单 %s 已经发货，我们将尽快为您送达，请注意查收。【#{shopname}】" % (trade.is_merged? ? TaobaoTrade.deleted.where(:_id.in => trade.merged_trade_ids).distinct(:tid).join(",") : trade.tid)
    end

    SmsNotifier.perform_async(content, mobile, trade.tid ,"after_send_goods") if content && mobile
  end

  def handle_response(trade)
    data = {parameters: {method: 'taobao.logistics.offline.send',tid: trade.tid,out_sid: trade.logistic_waybill,company_code: trade.logistic_code}}
    response = TaobaoQuery.get(data[:parameters],trade.trade_source_id)
    data.merge!({response: response,trade_source_id: trade.trade_source_id})
    throw :deliver_error, [trade,response["error_response"]["sub_msg"]] if cache_exception(message: "淘宝订单发货异常(#{trade.shop_name})",data: data) {
      fail if response["logistics_offline_send_response"]["shipping"]["is_success"] != true
    }
  end
end