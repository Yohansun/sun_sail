# -*- encoding : utf-8 -*-
class TradeTaobaoDeliver
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao
  
  def perform(id)
    code = false
    trade = TaobaoTrade.find(id)
    response = TaobaoQuery.get({
      method: 'taobao.logistics.offline.send',
      tid: trade.tid,
      out_sid: trade.logistic_waybill,
      company_code: trade.logistic_code}, trade.try(:trade_source_id)
    )

    if response['delivery_offline_send_response']
      response = response['delivery_offline_send_response']['shipping']
      code = response['is_succsess']
    end
    
    if code
      trade.orders.each do |order|
        product = Product.find_by_iid order.outer_iid
        stock_product = StockProduct.where(product_id: product.id, seller_id: trade.seller_id).first
        break unless product
        stock_product.update_quantity!(order.num, '发货')
        StockHistory.create!(
          operation: '发货',
          number: order.num,
          stock_product_id: stock_product.id,
          tid: trade.tid,
          seller_id: trade.seller_id
        )
      end
    end
  end
  
end
