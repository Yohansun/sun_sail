# == Schema Information
#
# Table name: logistics
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  options    :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  code       :string(255)     default("OTHER")
#  xml        :string(255)
#

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
