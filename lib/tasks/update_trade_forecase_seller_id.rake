
task :update_trade_forcase_seller_id => :environment do
  StockProduct.all.each do |stock_product|
    puts "stock_product:#{stock_product.id}"
    stock_product.update_attribute(:forecase, stock_product.activity)
  end

  offset, limit_count = 0, 100
  while true do
    trades = Array(Trade.skip(offset).limit(limit_count))
    trades.each_with_index do |trade, idx|
      puts "trade_id:#{trade.id}, idx:#{offset+idx}"
      forecase_seller_id = trade.matched_seller_with_default(nil).id rescue forecase_seller_id = nil
      if forecase_seller_id.present?
        puts "forecase_seller_id:#{forecase_seller_id}"
        trade.update_attribute(:forecase_seller_id, forecase_seller_id)
      end

      if trade.status == "WAIT_SELLER_SEND_GOODS" && trade.seller_id.blank?
        trade.update_seller_stock_forecase(trade.forcase_seller_id, "decrease")
      end
    end

    break if trades.length < limit_count
    offset += limit_count
  end
end