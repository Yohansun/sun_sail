class StockHistory < ActiveRecord::Base
	paginates_per 20

  attr_accessible :number, :operation, :stock_product_id, :tid, :reason, :note
  belongs_to :stock_product
  belongs_to :user
  belongs_to :seller

  validates_presence_of :stock_product_id, :number, :operation, :seller_id, :user_id
end
