# -*- encoding : utf-8 -*-
class TradeTaobaoPurchaseOrderDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao_purchase

  def perform(id)
    trade = TaobaoPurchaseOrder.find(id)
    return unless trade
    account = trade.fetch_account
    source_id = trade.trade_source_id
    response = TaobaoQuery.get({
      :method => 'taobao.logistics.offline.send', :tid => trade.deliver_id,
      :out_sid => trade.logistic_waybill,
      :company_code => trade.logistic_code}, source_id
     )

    errors = response['error_response']
    if errors.blank?
      trade = TradeDecorator.decorate(trade)
      #FIXME, MOVE LATER
      trade.nofity_stock "发货", trade.seller_id
    else
      Notifier.deliver_errors(id, errors, trade.account_id).deliver
      trade.unusual_states.build(reason: "发货异常#{errors['sub_msg']}", key: 'other_unusual_state', created_at: Time.now)
      trade.save
      trade.update_attributes!(status: 'WAIT_SELLER_SEND_GOODS')
    end
  end
end
