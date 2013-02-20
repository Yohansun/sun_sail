# -*- encoding : utf-8 -*-
class TradeTaobaoPurchaseOrderDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao_purchase

  def perform(id)
    trade = TaobaoPurchaseOrder.find(id)
    source_id = trade.trade_source_id || trade.fetch_account.settings.default_taobao_purchase_source_id
    response = TaobaoQuery.get({
      :method => 'taobao.logistics.offline.send', :tid => trade.deliver_id,
      :out_sid => trade.logistic_waybill,
      :company_code => trade.logistic_code}, source_id
     )

    errors = response['error_response']
    if errors.blank?
      trade = TradeDecorator.decorate(trade)
      # mobile = trade.receiver_mobile_phone
      # if trade.splitted?
      #   content = "亲您好，您的订单#{tid}已经发货，该订单将由地区发送，请注意查收。【#{TradeSetting.shopname_taobao}】"
      # else
      #   content = "亲您好，您的订单#{tid}已经发货，我们将尽快为您送达，请注意查收。【#{TradeSetting.shopname_taobao}】"
      # end

      # notify_kind = "after_send_goods"
      # if content && mobile
      #   SmsNotifier.perform_async(content, mobile, tid ,notify_kind)
      # end

      #FIXME, MOVE LATER
      trade.nofity_stock "发货", trade.seller_id
    else
      Notifier.deliver_errors(id, errors).deliver
      trade.unusual_states.build(reason: "发货异常#{errors['sub_msg']}", key: 'other_unusual_state', created_at: Time.now)
      trade.save
      trade.update_attributes!(status: 'WAIT_SELLER_SEND_GOODS')
    end
  end
end
