# -*- encoding : utf-8 -*-

class TaobaoProductsPuller
  class << self   

    def sync_pic(trade_source_id = nil)
      trade_source_id ||= TradeSetting.default_taobao_trade_source_id
      trade_source = TradeSource.find trade_source_id
      response = TaobaoQuery.get({method: 'taobao.products.get', nick: trade_source.taobao_app_token.taobao_user_nick, fields: 'pic_url, name'}, trade_source_id)   
      if  response['products_get_response']['products'].present? &&  response['products_get_response']['products']['product'].present?
        products = response['products_get_response']['products']['product']
        products.each do |product|
          local_product = Product.where(name: product['name']).first
          if local_product
            local_product.pic_url = product['pic_url']
            local_product.save!(validate: false)   
          end     
        end 
      end
    end 

    def create(trade_source_id = nil)
      trade_source_id ||= TradeSetting.default_taobao_trade_source_id
      trade_source = TradeSource.find trade_source_id
      response = TaobaoQuery.get({method: 'taobao.products.get', nick: trade_source.taobao_app_token.taobao_user_nick, fields: 'product_id, outer_id, cat_name, props_str, binds_str, name, price, pic_url'}, trade_source_id)         
      if  response['products_get_response']['products'].present? &&  response['products_get_response']['products']['product'].present?
        products = response['products_get_response']['products']['product']
        products.each do |product|
          local_product = Product.where(name: product['name']).first
          unless local_product
            local_product = Product.new(iid: product['outer_id'] || "changme",  taobao_id: product['product_id'], cat_name: product['cat_name'], props_str: product['props_str'], binds_str: product['binds_str'], name: product['name'], price: product['price'], pic_url: product['pic_url'])
            local_product.save!(validate: false)   
          end     
        end 
      end
    end
   end 
end
