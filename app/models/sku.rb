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
  def name
    sku_name = ''
    if properties_name.present?
      properties = properties_name.split(';')
      properties.each do |property|
        sku_values = property.split(':')
        sku_key =  sku_values[2]
        sku_value =  sku_values[3]
        sku_name = sku_name + sku_key + ':' + sku_value + '  '
      end  
    end
    sku_name
  end  
end
