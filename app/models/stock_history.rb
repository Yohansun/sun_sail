class StockHistory < ActiveRecord::Base
  attr_accessible :number, :operation, :stock_product_id, :tid, :reason, :note
  belongs_to :stock_product
  belongs_to :user
end
