# -*- encoding: utf-8 -*-
module Api
  module Trades
    def self.xml(trades)
      result = ::Builder::XmlMarkup.new
      result.trades do
        trades.each do |trade|
          account = trade.fetch_account
          result.trade do
            result.tid trade.tid
            result.receiver_name trade.receiver_name
            result.receiver_mobile_phone trade.receiver_mobile_phone
            result.receiver_phone trade.receiver_phone
            result.receiver_address trade.receiver_address
            result.receiver_district trade.receiver_district
            result.receiver_city trade.receiver_city
            result.receiver_state trade.receiver_state
            result.receiver_zip trade.receiver_zip
            result.trade_source_name trade.shop_name
            result.buyer_message trade.buyer_message
            result.buyer_nick trade.buyer_nick
            result.seller_memo trade.seller_memo
            result.post_fee trade.post_fee

            result.seller_discount trade.seller_discount - trade.shop_bonus
            result.sum_fee trade.sum_fee
            result.point_fee trade.point_fee
            result.total_fee trade.total_fee

            result.created trade.created.try(:strftime, "%Y-%m-%d %H:%M")
            result.pay_time trade.pay_time.try(:strftime, "%Y-%m-%d %H:%M")
            result.consign_time trade.consign_time.try(:strftime, "%Y-%m-%d %H:%M")
            result.cs_memo trade.cs_memo
            result.logistic_name trade.logistic_name

            result.promotion_details do
              trade.promotion_details.where(promotion_id: /^shopbonus/i).each do |promotion_detail|
                result.promotion_detail do
                  result.name promotion_detail.promotion_name
                  result.desc promotion_detail.promotion_desc
                  result.discount_fee promotion_detail.discount_fee
                  result.promotion_id promotion_detail.promotion_id
                end
              end
            end

            result.orders do
              trade.orders.each do |order|
                if order.sku_bindings.present?
                  order.sku_bindings.each do |binding|
                    sku_id = binding.sku_id
                    sku =  account.skus.find_by_id(sku_id)
                    product = sku.try(:product)
                    if product
                      taobao_product = account.taobao_products.find_by_outer_id(product.outer_id)
                      order_number = binding.number * order.num
                      result.order do
                        result.title product.name
                        result.num order_number
                        if order.price == 0
                          result.order_type "EA"
                        else
                          result.order_type "PK"
                        end
                        result.price (taobao_product.try(:price) || product.try(:price))
                        result.item_outer_id (taobao_product.try(:outer_id) || product.try(:outer_id))
                      end
                    end
                  end
                elsif order.local_skus.present?
                  order.local_skus.each do |sku|
                    sku_id = sku.id
                    sku = account.skus.find_by_id(sku_id)
                    product = sku.try(:product)
                    if product
                      taobao_product = account.taobao_products.find_by_outer_id(product.outer_id)
                      result.order do
                        result.title product.name
                        result.num order.num
                        if order.price == 0
                          result.order_type "EA"
                        else
                          result.order_type "PK"
                        end
                        result.price (taobao_product.try(:price) || product.try(:price))
                        result.item_outer_id (taobao_product.try(:outer_id) || product.try(:outer_id))
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      result.target!
    end
  end
end

