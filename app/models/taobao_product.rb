# -*- encoding : utf-8 -*-
class TaobaoProduct < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :taobao_skus, dependent: :destroy

  attr_accessible :name, :product_id, :outer_id, :price, :pic_url, :category_id, :cat_name, :detail_url, :num_iid, :cid, :account_id

  validates_uniqueness_of :outer_id, :allow_blank => true, message: "信息已存在"

end
