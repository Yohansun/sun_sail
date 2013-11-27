class SellerMatcher
  def self.match_item_seller(area, order)
    match_item_sellers(area, order).first
  end

  def self.match_item_sellers(area, order)
    seller_ids = []
    color_num = order.color_num
    color_num.delete('')
    order.skus_info_with_offline_refund.each do |info|
      stock_products = StockProduct.where(id: info.fetch(:stock_product_ids))
      avaliable_stock_products = stock_products.where("activity > #{info.fetch(:number)}")
      if color_num.present?
        color_num.each do |colors|
          next if colors.blank?
          colors = colors.shift(info.fetch(:number)).flatten.compact.uniq
          colors.delete('')
          avaliable_stock_products = avaliable_stock_products.select {|stock_product| (colors - stock_product.colors.map(&:num)).size == 0}
        end
      end
      seller_ids << avaliable_stock_products.map(&:seller_id)
    end
    seller_ids = seller_ids.compact.uniq
    sellers = area.sellers.where(id: seller_ids, active: true).reorder("performance_score DESC")
  end

  def self.match_trade_seller(trade_id, area)
    trade = Trade.find(trade_id)
    matched_sellers = nil
    trade.orders.each do |order|
      matched_sellers ||= match_item_sellers(area, order)
      matched_sellers = matched_sellers & match_item_sellers(area, order)
    end
    matched_sellers ||= []
    matched_sellers.first
  end
end
