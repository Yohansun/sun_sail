# == Schema Information
#
# Table name: colors
#
#  id         :integer(4)      not null, primary key
#  hexcode    :string(255)
#  name       :string(255)
#  num        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  account_id :integer(4)
#

# -*- encoding : utf-8 -*-
class Color < ActiveRecord::Base

  validates :name, presence: true
  validates :num, presence: true, uniqueness: { scope: :account_id }

  attr_accessible :num, :hexcode, :name

  has_many :colors_products
  has_many :products, through: :colors_products
  has_and_belongs_to_many :stock_products
end
