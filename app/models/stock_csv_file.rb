# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: stock_csv_files
#
#  id               :integer(4)      not null, primary key
#  path             :string(255)
#  upload_user_id   :integer(4)
#  stock_in_bill_id :string(255)
#  used             :boolean(1)
#  seller_id        :integer(4)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

class StockCsvFile < ActiveRecord::Base
  attr_protected []
  belongs_to :seller
  mount_uploader :path, StockCsvFileUploader

  validates_presence_of :path

  def verify_stock_csv_file(current_account)
    csv_mapper = CsvMapper.import(self.path.current_path) do
      start_at_row 1
      [id, sku_id, sku_name, num_iid, category, forecast, activity, actual, safe_value, storage_status]
    end
    if csv_mapper.slice(1..-1).each.find{|c| current_account.stock_products.find_by_id(c.id) == nil}.blank?
      return csv_mapper
    else
      self.delete
      return nil
    end
  end

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
        stock_product = current_account.stock_products.find(row[0])
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
