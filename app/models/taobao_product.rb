# -*- encoding : utf-8 -*-
class TaobaoProduct < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :taobao_skus, dependent: :destroy
  accepts_nested_attributes_for :taobao_skus, :allow_destroy => true

  attr_accessible :name, :product_id, :outer_id, :price, :pic_url, :category_id, :cat_name, :detail_url, :num_iid, :cid, :account_id,:sku_id,:taobao_skus_attributes
  # add validation
end
