#encoding: utf-8
# == Schema Information
#
# Table name: sellers
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  fullname          :string(255)
#  address           :string(255)
#  mobile            :string(255)
#  phone             :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  parent_id         :integer(4)
#  lft               :integer(4)
#  rgt               :integer(4)
#  children_count    :integer(4)      default(0)
#  email             :text
#  telephone         :string(255)
#  cc_emails         :text
#  user_id           :integer(4)
#  pinyin            :string(255)
#  active            :boolean(1)      default(TRUE)
#  performance_score :integer(4)      default(0)
#  interface         :string(255)
#  has_stock         :boolean(1)      default(FALSE)
#  stock_opened_at   :datetime
#  account_id        :integer(4)
#
require 'hz2py'

class Seller < ActiveRecord::Base
  include MagicEnum
  acts_as_nested_set :counter_cache => :children_count
  enum_attr :has_stock, [["启用",true],["禁用",false]]

  attr_accessible :has_stock, :stock_opened_at,:mobile, :telephone, :cc_emails, :email, :pinyin, :interface, :fullname, :name,
                  :parent_id, :address, :performance_score, :user_id,:stock_name,:stock_user_id

  has_many :users
  has_many :sellers_areas
  has_many :areas, through: :sellers_areas
  has_many :stock_products
  has_many :stock_history
  has_one :stock

  scope :with_account, lambda {|account_id| where(account_id: account_id)}

  validates :name, presence: true
  validates :fullname, presence: true, uniqueness: { scope: :account_id }


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

  def product_name(id)
    StockProduct.find_by_id(id).try(:product).try(:name)
  end

  def area_name(id)
    area = Area.find_by_id(id)
    area.self_and_ancestors.map(&:name).join('-') if area
  end

end
