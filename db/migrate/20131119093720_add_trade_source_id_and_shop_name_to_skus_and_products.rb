#encoding: utf-8
class AddTradeSourceIdAndShopNameToSkusAndProducts < ActiveRecord::Migration
  def change
    add_column :jingdong_skus     ,:trade_source_id   ,:integer
    add_column :jingdong_skus     ,:shop_name         ,:string
    add_column :jingdong_products ,:trade_source_id   ,:integer
    add_column :jingdong_products ,:shop_name         ,:string
    add_column :yihaodian_skus    ,:trade_source_id   ,:integer
    add_column :yihaodian_skus    ,:shop_name         ,:string
    add_column :yihaodian_products,:trade_source_id   ,:integer
    add_column :yihaodian_products,:shop_name         ,:string
    add_column :taobao_skus       ,:trade_source_id   ,:integer
    add_column :taobao_skus       ,:shop_name         ,:string
    add_column :taobao_products   ,:trade_source_id   ,:integer
    add_column :taobao_products   ,:shop_name         ,:string

    TradeSource.find_each do |trade_source|
      [JingdongSku,JingdongProduct,YihaodianSku,YihaodianProduct,TaobaoSku,TaobaoProduct].each do |klass|
        klass.where(account_id: trade_source.account_id).update_all(trade_source_id: trade_source.id,shop_name: trade_source.name)
      end
    end
  end
end