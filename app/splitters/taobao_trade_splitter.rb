# -*- encoding : utf-8 -*-

class TaobaoTradeSplitter
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

    count = grouped_orders.select{|key| !TradeSetting.trade_split_postfee_special_seller_ids.include?(key.to_i)}.size
    post_fee = (trade.post_fee / count).round(2)

    grouped_orders.each do |key, value|
      taotal_fee = value.inject(0.0) { |sum, el| sum + el.price * el.num }

      oids = value.map(&:oid)
      promotion_fee = trade.promotion_details.where(:oid.in => oids).inject(0.0) { |sum, el| sum + el.discount_fee }

      if TradeSetting.trade_split_postfee_special_seller_ids.include?(key.to_i)
        post_fee = 0.0
      end

      splitted_orders << {
        orders: value,
        post_fee: post_fee,
        default_seller: key,
        total_fee: value.inject(0.0) { |sum, el| sum + el.price * el.num },
        promotion_fee: promotion_fee,
        payment: taotal_fee + post_fee - promotion_fee
      }
    end

    splitted_orders
  end

  def self.match_item_sellers(area, order)
    sellers = nil
    op = Product.find_by_iid order.outer_iid
    return [] unless op
    return [] if area.blank?

    color_num = order.color_num
    color_num.delete('')
    op_package = op.package_info
    op_package << {
      iid: order.outer_iid,
      number: order.num,
      title: order.title
    } if op_package.blank?

    op_package.each do |pp|
      sql = "products.iid = '#{pp[:iid]}' AND stock_products.activity > #{pp[:number]}"
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
