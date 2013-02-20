# == Schema Information
#
# Table name: accounts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  key        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Account < ActiveRecord::Base
  include RailsSettings

  attr_accessible :key, :name

  has_and_belongs_to_many :users

  has_many :bbs_categories
  has_many :bbs_topics
  has_many :categories
  has_many :colors
  has_many :packages
  has_many :products
  has_many :quantities
  has_many :sales
  has_many :sellers
  has_many :settings
  has_many :stocks
  has_many :stock_histories
  has_many :stock_products
  has_many :features
  has_many :reconcile_statements
  has_many :logistics
  has_many :logistic_areas
  has_many :logistic_rates
  has_many :trade_sources

  # Warning: Don't use this method in the controller, if necessary please use current_account
  # This method should be work with any Model/Worker and other non-controllers.
  def self.current
    Thread.current[:account]
  end

  def self.current=(account)
    Thread.current[:account] = account
  end

end
