# -*- encoding : utf-8 -*-
class Color < ActiveRecord::Base
  validates_uniqueness_of :num
  validates_presence_of :num, :hexcode, :name
  attr_accessible :num, :hexcode, :name

  has_many :colors_products
  has_many :products, through: :colors_products
  has_and_belongs_to_many :stock_products
end
