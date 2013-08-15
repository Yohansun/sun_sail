# -*- encoding: utf-8 -*-
module Api
  module Trades
    def self.xml(trades)
      result = ::Builder::XmlMarkup.new
      result.trades do
        trades.each do |trade|
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
            result.trade_source_name trade.trade_source_name
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
                result.order do
                  result.title order.title
                  result.num order.num
                  if order.price == 0
                    result.order_type "EA"
                  else
                    result.order_type "PK"
                  end
                  result.price order.price
                  product = Product.find_by_num_iid(order.num_iid) || Product.find_by_cid(order.cid) || Sku.find_by_id(order.local_sku_id).try(:product)
                  result.item_outer_id (order.item_outer_id || product.try(:outer_id))
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
