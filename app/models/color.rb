# -*- encoding : utf-8 -*-
class Color < ActiveRecord::Base

  validates_uniqueness_of :num
  validates_presence_of :num, :hexcode, :name

  attr_accessible :num, :hexcode, :name

end
