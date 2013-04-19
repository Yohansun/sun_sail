# -*- encoding : utf-8 -*-
class Product < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  belongs_to :logistic_group
  has_many :feature_product_relationships
  #as_many :features, through: :feature_product_relationships
  #as_many :colors_products
  has_many :colors, through: :colors_products
  #has_many :packages
  has_many :stock_products
  has_many :skus
  has_many :taobao_products_products
  has_many :taobao_products, through: :taobao_products_products

  attr_accessible :name, :product_id, :outer_id, :storage_num, :price, :color_ids, :pic_url, :category_id, :features, :feature_ids, :cat_name, :detail_url, :num_iid, :cid, :account_id, :logistic_group_id

  validates_uniqueness_of :outer_id, :allow_blank => true, message: "信息已存在"
  validates_presence_of :name, :price, message: "信息不能为空"
  validates_numericality_of :price, message: "所填项必须为数字"
  validates_length_of :name, maximum: 100, message: "内容过长"

  def number(taobao_product_id)
    TaobaoProductsProduct.where(taobao_product_id: taobao_product_id, product_id: id).first.try(:number) || 1
  end  
end
