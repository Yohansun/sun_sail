class Stock < ActiveRecord::Base
  attr_accessible :name, :product_count, :seller_id, :stock_product_id
  belongs_to :seller
end
