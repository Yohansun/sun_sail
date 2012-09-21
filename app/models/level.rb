# -*- encoding : utf-8 -*-
class Level < ActiveRecord::Base
  has_many :products

  attr_accessible :name

  validates_uniqueness_of :name
  validates_presence_of :name

end