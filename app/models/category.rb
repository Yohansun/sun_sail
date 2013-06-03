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
#  status     :integer(4)      default(1)
#

class Category < ActiveRecord::Base
  include MagicEnum
  enum_attr :status,  [["禁用",0],["启用",1]]

  belongs_to :account
  acts_as_nested_set
  has_many :products
  has_and_belongs_to_many  :category_properties
  accepts_nested_attributes_for :category_properties#, :allow_destroy => true

  attr_accessible :name, :parent_id, :lft, :rgt,  :status, :category_property_ids

  validates :name, presence: true, uniqueness: { scope: :account_id }

end
