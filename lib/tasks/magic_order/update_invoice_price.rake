#encoding: utf-8
namespace :magic_order do
  desc "更新出库单开票金额"
  task :update_invoice_price => :environment do
    StockOutBill.where(:status.in => %w(CHECKED SYNCK_FAILED),stock_type: "OCM").each do |out_bill|
      next if out_bill.trade.nil?
      out_bill.update_attributes(:bill_products_price => out_bill.trade.invoice_price)
    end
  end
end