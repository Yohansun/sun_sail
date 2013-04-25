# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: stock_products
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  max        :integer(4)      default(0)
#  safe_value :integer(4)      default(0)
#  activity   :integer(4)      default(0)
#  actual     :integer(4)      default(0)
#  product_id :integer(4)
#  seller_id  :integer(4)
#  sku_id     :integer(8)
#  num_iid    :integer(8)
#  account_id :integer(4)
#

class StockProduct < ActiveRecord::Base
  paginates_per 20

  belongs_to :account

  attr_accessible :max, :safe_value, :product_id, :seller_id, :color_ids, :actual, :activity, :sku_id, :num_iid, :account_id

  validates_numericality_of :safe_value, :actual, :activity, :max, greater_than_or_equal_to: 0, message: '数量不能小于零'
  validates_numericality_of :activity, less_than_or_equal_to: :actual
  validates_presence_of :product_id, :account_id, message: '必填项'
  validates_uniqueness_of :sku_id, scope: :account_id, message: '必填项'
  belongs_to :product
  belongs_to :sku
  belongs_to :seller
  has_and_belongs_to_many :colors

end
