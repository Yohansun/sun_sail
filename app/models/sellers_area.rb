# == Schema Information
#
# Table name: sellers_areas
#
#  id         :integer(4)      not null, primary key
#  seller_id  :integer(4)
#  area_id    :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# -*- encoding : utf-8 -*-

class SellersArea < ActiveRecord::Base
  belongs_to :seller
  belongs_to :area
  attr_accessible :area_id, :seller_id
end
