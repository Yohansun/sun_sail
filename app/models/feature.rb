# == Schema Information
#
# Table name: features
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# -*- encoding : utf-8 -*-
class Feature < ActiveRecord::Base
  has_many :feature_product_relationships
  has_many :products, :through => :feature_product_relationships

  attr_accessible :name

  validates_uniqueness_of :name
  validates_presence_of :name
end
