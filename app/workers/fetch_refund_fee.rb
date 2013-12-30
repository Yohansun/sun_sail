# encoding: utf-8
class FetchRefundFee
  include Sidekiq::Worker
  sidekiq_options :queue => :fetch_refund_fee, unique: true, unique_job_expiration: 1200

  def perform(id)
    trade = Trade.where(id: id).first or return

    trade.orders.each do |order|
      order.refund_fee = order.fetch_refund_price
    end
    trade.save(validate: false)
    stock_out_bill = trade.stock_out_bill
    return if stock_out_bill.nil?
    stock_out_bill.update_invoice_price(invoice_price(stock_out_bill,trade))
  end
  
  def invoice_price(stock_out_bill,trade)
    stock_out_bill.bill_products_price - trade.orders.sum(:refund_fee)
  end
end