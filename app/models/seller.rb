# -*- encoding : utf-8 -*-
require 'hz2py'

class Seller < ActiveRecord::Base
  acts_as_nested_set :counter_cache => :children_count

  has_many :sellers_users
  has_many :users, :through => :sellers_users
  has_many :areas_sellers
  has_many :areas, :through => :areas_sellers

  validates_uniqueness_of :name
  validates_presence_of :name, :fullname

  before_save :set_pinyin

  def set_pinyin
    self.pinyin = Hz2py.do(name).split(" ").map { |name| name[0, 1] }.join
  end
end