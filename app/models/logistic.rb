# -*- encoding : utf-8 -*-
class Logistic < ActiveRecord::Base

  attr_accessible :name

  has_many :logistic_areas
  has_many :areas, through: :logistic_areas ,:dependent => :destroy
  has_many :users
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :code
  validates_uniqueness_of :code
end
