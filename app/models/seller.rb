# -*- encoding : utf-8 -*-
require 'hz2py'

class Seller < ActiveRecord::Base
  acts_as_nested_set :counter_cache => :children_count

  attr_accessible :has_stock, :mobile, :telephone, :cc_emails, :email, :pinyin, :interface,:fullname, :name, :email,
                  :parent_id, :address, :performance_score

  has_many :users
  has_many :sellers_areas
  has_many :areas, through: :sellers_areas
  has_many :stock_products
  has_many :stock_history
  has_one :stock

  validates_presence_of :fullname, :name, :mobile, :email
  validates_uniqueness_of :fullname, :name
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
  
  def products_ids
    @products_ids = self.stock_products.select("distinct stock_products.product_id").map(&:product_id)
  end 
  
  def categories_ids
    products_ids = self.products_ids
    if products_ids.present?
      products = Product.where("products.id in (#{products_ids.join(',')})")
      @categories_ids = products.select("distinct category_id").map(&:category_id)
    else
      @categories_ids = []
    end
  end    
end