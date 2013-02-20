# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: categories
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  parent_id  :integer(4)
#  lft        :integer(4)
#  rgt        :integer(4)
#  depth      :integer(4)
#  account_id :integer(4)
#

class Category < ActiveRecord::Base
  acts_as_nested_set
  has_many :products

  attr_accessible :name, :parent_id, :lft, :rgt

  validates :name, presence: true, uniqueness: { scope: :account_id }


end
