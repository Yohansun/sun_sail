# # -*- encoding: utf-8 -*-
# module Dulux
#   module Splitter
#     def matched_seller_info(trade)
#       # 向view层传递拆分信息
#       info = []
#       match_seller_with_conditions(trade).each do |split|
#         seller = Seller.find_by_id(split[:default_seller])

#         if seller
#           seller_id = seller.id
#           seller_name = seller.name
#         else
#           seller = trade.default_area.sellers.where(account_id: trade.account_id).first
#           seller_id = seller ? seller.id : nil
#           seller_name = seller ? "#{seller.name}: 库存不足" : '无对应经销商'
#         end

#         info << {
#           orders: split[:orders].map{ |order| {title: order.title, outer_iid: order.outer_iid, num: order.num, color_num: order.color_num.first} },
#           seller_id: seller_id,
#           seller_name: seller_name,
#           error: seller_name.include?("库存不足")
#         }
#       end

#       info
#     end

#     def match_seller_with_conditions(trade)
#       # 拆分商品
#       # 运费还没有计算
#       grouped_orders = {}
#       splitted_orders = []
#       rebuild_orders = []

#       trade.orders.each do |order|
#         if order.color_num.blank?
#           rebuild_orders << order
#         else
#           rebuild_orders += split_by_colors(order)
#         end
#       end

#       rebuild_orders.each do |order|
#         seller = SellerMatcher.match_item_seller(trade.default_area, order)
#         seller_id = seller ? seller.id : 0
#         tmp = grouped_orders["#{seller_id}"] || []
#         tmp << order
#         grouped_orders["#{seller_id}"] = tmp
#       end

#       post_fee = (trade.post_fee / grouped_orders.size).round(2)

#       grouped_orders.each do |key, value|
#         total_fee = value.inject(0.0) { |sum, el| sum + el.price * el.num }

#         oids = value.map(&:oid)
#         promotion_fee = trade.promotion_details.where(:oid.in => oids).inject(0.0) { |sum, el| sum + el.discount_fee }

#         splitted_orders << {
#           orders: value,
#           post_fee: post_fee,
#           default_seller: key,
#           total_fee: total_fee,
#           promotion_fee: promotion_fee,
#           payment: total_fee + post_fee - promotion_fee
#         }
#       end

#       splitted_orders
#     end


#     # 适用于手动选择拆分经销商
#     # def manual_match_seller_with_conditions(trade, split_hash)
#     #   return if split_hash.blank?
#     #   grouped_orders = {}
#     #   splitted_orders = []

#     #   split_hash.each do |split|
#     #     tmp = grouped_orders["#{split[:seller_id]}"] || []
#     #     order = trade.orders.select{|order| order.outer_iid == split[:order_id]}.first
#     #     s_order = split_by_color(order, split[:color_num], split[:num])
#     #     tmp << s_order
#     #     grouped_orders["#{split[:seller_id]}"] = tmp
#     #   end

#     #   grouped_orders.each do |key, value|
#     #     splitted_orders << {
#     #       orders: value,
#     #       post_fee: 0,
#     #       default_seller: key,
#     #       total_fee: value.inject(0) { |sum, el| sum + el.total_fee }
#     #     }
#     #   end

#     #   splitted_orders
#     # end

#     def split_by_color(order, num, count)
#       count = count.to_i
#       c_order = TaobaoOrder.new(order.attributes)
#       c_order.num = count
#       color = Color.find_by_num num

#       c_order.color_num = color ? Array.new(count, num) : []
#       c_order.color_hexcode = color ? Array.new(count, color.hexcode) : []
#       c_order.color_name = color ? Array.new(count, color.name) : []
#       c_order[:total_fee] = order.total_fee - count * order.price
#       c_order
#     end

#     def split_by_colors(order)
#       grouped_orders = {}
#       splitted_orders = []

#       order.color_num.each do |num|
#         num ||= "0"
#         tmp = grouped_orders["#{num}"] || 0
#         grouped_orders["#{num}"] = (tmp += 1)
#       end

#       grouped_orders.each do |num, count|
#         splitted_orders << split_by_color(order, num, count)
#       end

#       splitted_orders
#     end

#     def split_orders(trade, auto=true, split_hash=[])
#       # 拆单并分流
#       trade_dec = TradeDecorator.decorate(trade)
#       return false unless trade_dec.pay_time.present? && trade.seller_id.blank?

#       area = trade.default_area
#       return false unless area

#       splitted_orders = []

#       if auto
#         splitted_orders = match_seller_with_conditions(trade)
#       else
#         splitted_orders = manual_match_seller_with_conditions(trade, split_hash)
#       end

#       return false if splitted_orders.size == 1

#       new_trade_ids = []

#       # 复制创建新 trade
#       splitted_trades = []
#       splitted_orders.each_with_index do |splitted_order, index|
#         new_trade = trade.clone
#         new_trade.orders = splitted_order[:orders]
#         new_trade.splitted_tid = "#{trade.tid}-#{index+1}"

#         # TODO 完善物流费用拆分逻辑
#         new_trade.post_fee = splitted_order[:post_fee]
#         new_trade.total_fee = splitted_order[:total_fee]
#         new_trade.payment = new_trade.orders.sum(:payment)
#         new_trade.splitted = true
#         new_trade.has_color_info = new_trade.orders.any?{|order| order.color_num.present?}

#         new_trade.save
#         new_trade_ids << new_trade.id
#       end

#       # 删除旧 trade
#       trade.delete

#       new_trade_ids
#     end
#   end

#   module SellerMatcher
#     class << self
#       def match_item_seller(area, order)
#         match_item_sellers(area, order).first
#       end

#       def match_item_sellers(area, order)
#         sellers = nil
#         op = Product.find_by_outer_id order.outer_iid
#         return [] unless op
#         color_num = order.color_num
#         color_num.delete('')
#         op_package = op.package_info
#         op_package << {
#           outer_id: order.outer_iid,
#           number: order.num,
#           title: order.title
#         } if op_package.blank?

#         op_package.each do |pp|
#           sql = "products.outer_id = '#{pp[:outer_id]}' AND stock_products.activity > #{pp[:number]}"
#           products = StockProduct.joins(:product).where(sql)

#           if op.account.settings.enable_match_seller_user_color && color_num.present?
#             color_num.each do |colors|
#               next if colors.blank?
#               colors = colors.shift(pp[:number]).flatten.compact.uniq
#               colors.delete('')
#               products = products.select {|p| (colors - p.colors.map(&:num)).size == 0}
#             end
#           end

#           product_seller_ids = products.map &:seller_id
#           a_sellers = area.sellers.where(id: product_seller_ids, active: true, account_id: order.account_id).reorder("performance_score DESC")
#           if sellers
#             sellers = sellers & a_sellers
#           else
#             sellers = a_sellers
#           end
#         end
#         sellers
#       end

#       def match_trade_seller(trade, area)
#         matched_sellers = nil
#         trade.orders.each do |o|
#           matched_sellers ||= match_item_sellers(area, o)
#           matched_sellers = matched_sellers & match_item_sellers(area, o)
#         end

#         matched_sellers ||= []
#         matched_sellers.first
#       end
#     end
#   end
# end