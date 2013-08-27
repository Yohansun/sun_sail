# encoding: utf-8
desc "重新设置stock_products的预测库存（forecase）"
task :update_trade_forecast_seller_id => :environment do
  StockProduct.all.each do |stock_product|
    puts "stock_product:#{stock_product.id}"
    stock_product.update_attribute(:forecast, stock_product.activity)
  end

  offset, limit_count = 0, 100
  while true do
    trades = Array(Trade.where(status: 'WAIT_SELLER_SEND_GOODS', seller_id: nil).skip(offset).limit(limit_count))
    trades.each_with_index do |trade, idx|
      puts "trade_id:#{trade.id}, idx:#{offset+idx}"
      next if trade.forecast_seller_id.present?
      forecast_seller_id = trade.matched_seller_with_default(nil).id rescue forecast_seller_id = nil
      if forecast_seller_id.present?
        puts "forecast_seller_id:#{forecast_seller_id}"
        trade.update_attribute(:forecast_seller_id, forecast_seller_id)
      end

      if trade.status == "WAIT_SELLER_SEND_GOODS" && trade.seller_id.blank?
        trade.update_seller_stock_forecast(trade.forecast_seller_id, "decrease")
      end
    end

    break if trades.length < limit_count
    offset += limit_count
  end
end