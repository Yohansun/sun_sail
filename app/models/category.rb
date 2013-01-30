# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: categories
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Category < ActiveRecord::Base
  acts_as_nested_set	
  has_many :products

  attr_accessible :name, :parent_id, :lft, :rgt

  validates_uniqueness_of :name
  validates_presence_of :name

end
