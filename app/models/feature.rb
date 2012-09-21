# -*- encoding : utf-8 -*-
class Feature < ActiveRecord::Base
  has_many :feature_product_relationships
  has_many :products, :through => :feature_product_relationships

  attr_accessible :name

  validates_uniqueness_of :name
  validates_presence_of :name
end