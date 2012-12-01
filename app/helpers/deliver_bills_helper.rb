module DeliverBillsHelper
  def item_count(bill)
    bill.bill_products.sum(:number)
  end
end