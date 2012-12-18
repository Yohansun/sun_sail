# == Schema Information
#
# Table name: stock_histories
#
#  id               :integer(4)      not null, primary key
#  operation        :string(255)
#  number           :integer(4)
#  stock_product_id :integer(4)
#  tid              :string(255)
#  user_id          :integer(4)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  reason           :string(255)
#  note             :string(255)
#  seller_id        :integer(4)
#
require 'spec_helper'

describe StockHistory do
end
