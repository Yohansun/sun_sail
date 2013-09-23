# encoding: utf-8
task :manual_update_stock_activity=> :environment do
  account_id = ENV['account_id']
  StockProduct.where(account_id: account_id).find_each do |stock_product|
    stock_product.activity = stock_product.actual
    stock_product.save
  end
  stock_out_bills = StockOutBill.where(account_id: account_id).where(status: ['CHCKED', 'SYNCKED','SYNC_FAILED'])
  stock_out_bills.each do |bill|
    bill.decrease_activity
  end
end