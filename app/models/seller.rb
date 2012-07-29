# -*- encoding : utf-8 -*-
require 'hz2py'

class Seller < ActiveRecord::Base
  acts_as_nested_set :counter_cache => :children_count

  has_many :users
  has_many :areas

  validates_uniqueness_of :name
  validates_presence_of :name, :fullname

  before_save :set_pinyin

  def set_pinyin
    self.pinyin = Hz2py.do(name).split(" ").map { |name| name[0, 1] }.join
  end

  def interface_mobile
    self.parent.mobile if self.parent
  end

  def interface_email
    self.parent.email if self.parent
  end

  def interface_name
    self.parent.name if self.parent
  end
end