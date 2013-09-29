#encoding: utf-8
module StocksHelper
  def stock_bill_name(stock_bill)
    if stock_bill.is_a?(StockOutBill)
      "出库"
    elsif stock_bill.is_a?(StockInBill)
      "入库"
    else
      ''
    end
  end
end
