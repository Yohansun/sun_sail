# -*- encoding : utf-8 -*-
class TradeTaobaoDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao

  def perform(id)
    trade = Trade.find(id)
    return unless trade
    account = trade.fetch_account
    tid = trade.tid
    source_id = trade.trade_source_id
    if trade._type != "CustomTrade"

      if trade.is_merged?
        # STORY #982 订单管理-订单发货 合并订单发货物流信息返回到淘宝订单
        # A B订单被合并成C订单了，现在C订单只会返回一个物流单号，但淘宝那边还是两个订单，而且不同订单需要填写不同的物流单号
        # 解决方案：A订单回馈C订单的物流单号，而B订单的物流单号就写其他
        trades = Trade.find trade.merged_trade_ids
        errors = []
        trades.each_with_index{|merged_trade,index|

          if index == 0
            logistic_waybill = trade.logistic_waybill
            logistic_code = trade.logistic_code
          else
            logistic_waybill = "其它"
            logistic_code = "其它"
          end

          if merged_trade.is_a? TaobaoTrade
            response = TaobaoQuery.get({
              method: 'taobao.logistics.offline.send',
              tid: merged_trade.tid,
              out_sid: logistic_waybill,
              company_code: logistic_code}, merged_trade.trade_source_id
            )
            errors << response['error_response']
          end
        }



      else
        response = TaobaoQuery.get({
          method: 'taobao.logistics.offline.send',
          tid: trade.tid,
          out_sid: trade.logistic_waybill,
          company_code: trade.logistic_code}, source_id
        )
        errors = response['error_response']
      end







      if errors.blank?
        trade = TradeDecorator.decorate(trade)
        mobile = trade.receiver_mobile_phone
        shopname = account.settings.shopname_taobao
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
        trade.unusual_states.build(reason: "发货异常#{errors['sub_msg']}", key: 'other_unusual_state', created_at: Time.now)
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