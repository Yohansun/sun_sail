# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: skus
#
#  id              :integer(4)      not null, primary key
#  sku_id          :integer(8)
#  num_iid         :integer(8)
#  properties      :string(255)     default("")
#  properties_name :string(255)     default("")
#  quantity        :integer(4)
#  product_id      :integer(4)
#

class Sku < ActiveRecord::Base
  attr_accessible :num_iid, :properties, :properties_name, :quantity, :sku_id, :product_id
  belongs_to :product
  has_many :stock_products
end
