# -*- encoding : utf-8 -*-
class Logistic < ActiveRecord::Base
  mount_uploader :xml, LogisticXmlUploader
  attr_accessible :name, :code, :xml

  has_many :logistic_areas
  has_many :areas, through: :logistic_areas ,:dependent => :destroy
  has_many :users
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :code
end
