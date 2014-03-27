class SellerMatcher
  def self.match_item_seller(area, order)
    match_item_sellers(area, order).first
  end

  def self.match_item_sellers(area, order)
    seller_ids = []
    order.skus_info_with_offline_refund.each do |info|
      stock_products = StockProduct.where(id: info.fetch(:stock_product_ids))
      avaliable_stock_products = stock_products.where("activity > #{info.fetch(:number)}")
      seller_ids << avaliable_stock_products.map(&:seller_id)
    end
    seller_ids = seller_ids.compact.uniq
    sellers = area.sellers.where(id: seller_ids, active: true, trade_type: order._type.gsub(/Order|Trade/, '')).reorder("performance_score DESC")
  end

  def self.match_trade_seller(trade_id, area)
    trade = Trade.unscoped.where(id: trade_id).first or return
    matched_sellers = nil
    trade.orders.each do |order|
      next if order.skus_info_with_offline_refund.blank?
      matched_sellers ||= SellerMatcher.match_item_sellers(area, order)
      matched_sellers = matched_sellers & SellerMatcher.match_item_sellers(area, order)
    end
    matched_sellers ||= []
    matched_sellers.first
  end
end