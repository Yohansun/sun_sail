# == Schema Information
#
# Table name: stock_products
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  max        :integer(4)      default(0)
#  safe_value :integer(4)      default(0)
#  activity   :integer(4)      default(0)
#  actual     :integer(4)      default(0)
#  product_id :integer(4)
#  seller_id  :integer(4)
#

require 'spec_helper'

describe StockProduct do
end