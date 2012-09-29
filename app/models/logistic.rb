# -*- encoding : utf-8 -*-
class Logistic < ActiveRecord::Base
  has_many :logistic_areas
  has_many :areas, through: :logistic_areas ,:dependent => :destroy
  validates_presence_of :name
  validates_uniqueness_of :name
end
