class DeliverBill
  include Mongoid::Document

  field :account_id,     type: Integer
  field :deliver_bill_number, type: String
  field :seller_id, type: Integer
  field :seller_name, type: String
  field :deliver_printed_at, type: DateTime
  field :logistic_printed_at, type: DateTime

  belongs_to :trade, counter_cache: true
  embeds_many :bill_products,:inverse_of => :deliver_bill
  embeds_many :print_batches

  def logistic=(logistic)
    update_attributes logistic_id: logistic.id, logistic_name: logistic.name
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
  
  private
  def duplicate
    self.clone
  end
end
