class DeliverBill
  include Mongoid::Document

  field :account_id,     type: Integer
  field :deliver_bill_number, type: String
  field :seller_id, type: Integer
  field :seller_name, type: String
  field :deliver_printed_at, type: DateTime
  field :logistic_printed_at, type: DateTime
  field :process_sheet_printed_at, type: DateTime

  belongs_to :trade, counter_cache: true
  embeds_many :bill_products,:inverse_of => :deliver_bill
  embeds_many :print_batches

  def logistic=(logistic)
    update_attributes logistic_id: logistic.id, logistic_name: logistic.name
  end

  def except_ref_bills
    adapted_bill_products = bill_products
    if trade.return_money_batch_orders
      adapted_bill_products.each do |product|
        product_num = product[:number]
        ref_order = trade.return_money_batch_orders.each.find{|o| o.sku_id.to_i == product[:sku_id] }
        product_num -= ref_order[:num] if ref_order
        product_num == 0 ? adapted_orders.delete(product) : product[:num] = product_num
      end
    end
    adapted_bill_products
  end

  # bill = DeliverBill.find(params[:id])
  # params[:partition]
  # => {"1" => [1,2,3],"2" => [4,5,6],"3" => [7,8,9]}
  # bill.split_invoice(params[:partition].values)
  def split_invoice(hashs={})
    duplicates = []
    hashs.each_pair do |key,ids|
      @dupclicate,ids = duplicate,ids.map(&:to_s)
      @dupclicate.bill_products = bill_products.select {|bill| ids.include?(bill.id.to_s)}
      @dupclicate.deliver_bill_number = Time.now.to_f.to_s.delete(".")
      @dupclicate.id = DeliverBill.new.id
      duplicates << @dupclicate
    end
    duplicates.map(&:save!)
    self.destroy
  end

  def batch_num
    print_batches.last.try(:batch_num)
  end

  def serial_num
    print_batches.last.try(:serial_num)
  end

  private
  def duplicate
    self.clone
  end
end
