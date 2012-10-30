# -*- encoding : utf-8 -*-
class TradeTaobaoDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao

  def perform(id)
    code = true
    trade = TaobaoTrade.find(id)
    tid = trade.tid
    response = TaobaoQuery.get({
      method: 'taobao.logistics.offline.send',
      tid: trade.tid,
      out_sid: trade.logistic_waybill,
      company_code: trade.logistic_code}, trade.try(:trade_source_id)
    )

    errors = response['error_response']
    code = false if errors.present?

    if code
      trade.update_attributes!(status: 'WAIT_BUYER_CONFIRM_GOODS')
      
      trade = TradeDecorator.decorate(trade)
      mobile = trade.receiver_mobile_phone
      if trade.splitted?
        content = "亲您好，您的订单#{tid}已经发货，该订单将由地区发送，请注意查收。【天猫多乐士店】"
      else
        content = "亲您好，您的订单#{tid}已经发货，我们将尽快为您送达，请注意查收。【天猫多乐士店】"
      end
      notify_kind = "after_send_goods"
      if content && mobile
        SmsNotifier.perform_async(content, mobile, tid ,notify_kind) 
      end
      
      #FIXME, MOVE LATER                     
      trade.orders.each do |order|
        product = Product.find_by_iid order.outer_iid
        stock_product = StockProduct.where(product_id: product.id, seller_id: trade.seller_id).first
        break unless product
        stock_product.update_quantity!(order.num, '发货', tid)
        StockHistory.create!(
          operation: '发货',
          number: order.num,
          stock_product_id: stock_product.id,
          tid: trade.tid,
          seller_id: trade.seller_id
        )
      end
    else
      Notifier.deliver_errors(id, errors).deliver
    end
  end
  
end
