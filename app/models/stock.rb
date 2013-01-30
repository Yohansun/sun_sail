# == Schema Information
#
# Table name: stocks
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  seller_id        :integer(4)
#  product_count    :integer(4)      default(0)
#  stock_product_id :integer(4)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  account_id       :integer(4)
#

class Stock < ActiveRecord::Base
  attr_accessible :name, :product_count, :seller_id, :stock_product_id
  belongs_to :seller
end
