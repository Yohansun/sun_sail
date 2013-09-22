# -*- encoding : utf-8 -*-
class StockCsvFile < ActiveRecord::Base
  attr_protected []
  mount_uploader :path, StockCsvFileUploader

  validates_presence_of :path

  def create_stock_in_bill(current_account)
    stock_in_bill = StockInBill.new(stock_type: "IINITIAL",
                                    account_id: current_account.id,
                                    seller_id: current_account.sellers.first.id,
                                    status: "CREATED")

    index = 0

    File.open(self.path.current_path) do |file|
      CSV.parse(file) do |row|
        index +=1
        next if index < 3
        stock_product = StockProduct.find(row[0])
        product = stock_product.product
        sku = stock_product.sku

        stock_in_bill.bill_products.build(title: sku.title,
                                          outer_id: product.outer_id,
                                          num_iid: product.num_iid,
                                          stock_product_id: stock_product.id,
                                          sku_id: sku.id,
                                          number: row[7],
                                          real_number: row[7])

      end
    end
    stock_in_bill.bill_products_mumber = stock_in_bill.bill_products.sum(:number)
    stock_in_bill.bill_products_real_mumber = stock_in_bill.bill_products.sum(:real_number)
    stock_in_bill.save!
    self.update_attributes(stock_in_bill_id: stock_in_bill.id.to_s)
  end

end
