# == Schema Information
#
# Table name: quantities
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  account_id :integer(4)
#

# -*- encoding : utf-8 -*-
class Quantity < ActiveRecord::Base
  belongs_to :account
  has_many :products

  attr_accessible :name

  validates_uniqueness_of :name
  validates_presence_of :name

end
