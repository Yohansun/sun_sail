# -*- encoding : utf-8 -*-
require 'hz2py'

class Seller < ActiveRecord::Base
  acts_as_nested_set :counter_cache => :children_count

  attr_accessible :mobile, :telephone, :cc_emails, :email, :pinyin, :interface,:fullname, :name, :email,:parent_id, :address, :performance_score

  has_many :users
  has_many :areas
  has_many :stock_products
  has_many :stock_history

  validates_presence_of :fullname, :name, :mobile, :email
  validates_uniqueness_of :fullname, :name, :mobile, :email
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
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