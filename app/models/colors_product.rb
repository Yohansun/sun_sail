# == Schema Information
#
# Table name: colors_products
#
#  id         :integer(4)      not null, primary key
#  color_id   :integer(4)
#  product_id :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# -*- encoding : utf-8 -*-
class ColorsProduct < ActiveRecord::Base
  belongs_to :color
  belongs_to :product
end
