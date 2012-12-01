class DeliverBill
  include Mongoid::Document

  field :deliver_bill_number, type: String
  field :seller_id: type: Integer
  field :seller_name: type: String
  field :deliver_printed_at, type: DateTime
  field :logistic_printed_at, type: DateTime

  belongs_to :trade
  embeds_many :bill_products

  def logistic=(logistic)
    update_attributes logistic_id: logistic.id, logistic_name: logistic.name
  end
end
