# == Schema Information
#
# Table name: sku_bindings
#
#  id            :integer(4)      not null, primary key
#  sku_id        :integer(8)
#  number        :integer(8)
#  resource_id   :integer(4)
#  resource_type :string(255)
#

class SkuBinding < ActiveRecord::Base
  attr_protected []
  belongs_to :resource,:polymorphic => true,:include => :skus
  belongs_to :sku
end
