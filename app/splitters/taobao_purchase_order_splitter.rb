# -*- encoding : utf-8 -*-

class TaobaoPurchaseOrderSplitter
  def self.split_orders(trade)
    # 拆分商品
    # 运费还没有计算
    grouped_orders = {}
    splitted_orders = []

    trade.orders.each do |order|
      seller = match_item_sellers(trade.default_area, order).first
      seller_id = seller ? seller.id : 0
      tmp = grouped_orders["#{seller_id}"] || []
      tmp << order
      grouped_orders["#{seller_id}"] = tmp
    end

    trade_split_postfee_special_seller_ids = trade.fetch_account.settings.trade_split_postfee_special_seller_ids || []

    count = grouped_orders.select{|key| !trade_split_postfee_special_seller_ids.include?(key.to_i)}.size

    grouped_orders.each do |key, value|
      total_fee = value.inject(0.0) {|sum, el| sum + el.price * el.num}

      if trade_split_postfee_special_seller_ids.include?(key.to_i)
        splitted_orders << {
          orders: value,
          post_fee: 0.0,
          default_seller: key,
          total_fee: total_fee
        }
      else
        splitted_orders << {
          orders: value,
          post_fee: (trade.post_fee / count).round(2),
          default_seller: key,
          total_fee: total_fee
        }
      end
    end

    splitted_orders
  end

  def self.match_item_sellers(area, order)
    sellers = nil
    color_num = order.color_num
    color_num.delete('')
    order.skus_info.each do |info|
      sql = "products.outer_id = '#{info[:outer_id]}' AND stock_products.activity > #{info[:number]}"
      products = StockProduct.joins(:product).where(sql)

      product_seller_ids = products.map &:seller_id
      a_sellers = area.sellers.where(id: product_seller_ids, active: true).reorder("performance_score DESC")
      if sellers
        sellers = sellers & a_sellers
      else
        sellers = a_sellers
      end
    end
    sellers
  end
end
