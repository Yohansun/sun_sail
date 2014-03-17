# -*- encoding : utf-8 -*-
class TradeObserver < Mongoid::Observer

  observe :trade

  def around_save(object)

    yield

    # 订单付款提醒
    if object.status_changed? && object.is_paid_not_delivered && object.pay_time_changed? && object.pay_time.present?
      send_sms_to_buyer(object)
    end

    # 订单发货操作
    if object.delivered_at_changed? && object.delivered_at.present? && object.logistic_waybill.present?
      object.deliver!
      return
    end

    # 订单分派提醒
    if object.seller_id_changed? && object.seller_id.present? && object.dispatched_at_changed? && object.dispatched_at.present?
      dispatch_notify(object)
    end

    ### MAYBE DEPRECATED START ###

    # if object.fetch_account.key == "dulux" && object._type == "TaobaoTrade" && object.status_changed? && object.status == "TRADE_FINISHED" && !object.has_sent_send_logistic_rate_sms
    #   send_rate_sms_to_buyer(object)
    #   create_rate_record(object)
    #   object.has_sent_send_logistic_rate_sms = true
    # end

    # if object.request_return_at_changed? && object.request_return_at.present?
    #   send_return_sms_to_seller(object)
    # end

    ### MAYBE DEPRECATED END ###
  end

  def around_update(object)

    yield

    ## TODO: 合并了的订单目前依靠这一段代码更新基本信息,
    ##       但是目前合并订单相关订单都无法通过接口更新,以后希望可以通过接口更新

    if object._type == "Trade"
      trades = Trade.deleted.where(:_id.in => object.merged_trade_ids)
      object.changes.each do |key, value|
        next if ["seller_memo",
                 "cs_memo",
                 "gift_memo",
                 "buyer_message",
                 "promotion_fee",
                 "total_fee",
                 "payment",
                 "merged_trade_ids"].include?(key)
        trades.update_all(key.to_sym => value[1])
      end
    end
  end

  protected

  def dispatch_notify(trade)
    account = trade.fetch_account
    result  = account.can_auto_notify_right_now
    if account.can_send_sms('dispatch_notify')
      TradeDispatchSms.perform_in(result, trade.id, trade.seller_id, 'new')
    end
    if account.can_send_email('dispatch_notify')
      TradeDispatchEmail.perform_in(result, trade.id, trade.seller_id, 'new')
    end
  end

  def send_sms_to_buyer(trade)
    account = trade.fetch_account
    if account.can_send_sms('paid_notify')
      result      = account.can_auto_notify_right_now
      trade       = TradeDecorator.decorate(trade)
      mobile      = trade.receiver_mobile_phone
      trade_tid   = trade.tid
      shopname    = trade.seller_nick
      content     = "亲您好，感谢您的购买，您的订单号为#{trade_tid}，我们会尽快为您安排发货。【#{shopname}】"
      notify_kind = "before_send_goods"

      if content && mobile
        SmsNotifier.perform_in(result, content, mobile, trade_tid ,notify_kind)
      end
    end
  end

  ### MAYBE DEPRECATED START ###

  # def create_rate_record(trade)
  #   logistic_id = trade.logistic_id
  #   seller_id = trade.seller_id
  #   mobile = trade.receiver_mobile
  #   tid = trade.tid
  #   LogisticRate.create(send_at: Time.now, seller_id: seller_id, mobile: mobile, tid: tid, logistic_id: logistic_id)
  # end

  # def send_rate_sms_to_buyer(trade)
  #   mobile = trade.receiver_mobile
  #   trade_tid = trade.tid
  #   notify_kind = "rate_sms_to_buyer"
  #   content = "亲，感谢您对【#{trade.fetch_account.settings.shopname_taobao}】的支持，若您对本次物流服务满意请回复“5“，若觉得物流有待提升请回复“3”，若觉得很不满意请回复“1“，本条短信回复免费。【#{trade.fetch_account.settings.shopname_taobao}】"
  #   if content && mobile
  #     SmsNotifier.perform_async(content, mobile, trade_tid ,notify_kind)
  #   end
  # end

  # def send_return_sms_to_seller(trade)
  #   trade_decorator = TradeDecorator.decorate(trade)
  #   content = "#{trade.seller.try(:name)}经销商您好，您有一笔退货订单需要处理。订单号：#{trade.tid}，买家姓名：#{trade_decorator.receiver_name}，手机：#{trade_decorator.receiver_mobile_phone}，请尽快登录系统查看！"
  #   SmsNotifier.perform_async(content, trade.seller.try(:mobile), trade.tid, 'request_return')
  # end

  ### MAYBE DEPRECATED END ###
end
