#encoding: utf-8
class YihaodianProduct < ActiveRecord::Base
  include MagicEnum
  attr_protected []
  validates :product_code,:product_cname ,:presence => true
  has_many :yihaodian_skus, :class_name => "YihaodianSku", :foreign_key => "product_id",:primary_key => "product_id",:dependent => :destroy
  enum_attr :can_sale,[["下架",0],["上架",1]]
  enum_attr :verify_flg,[["新增未审核",1],["编辑待审核",2],["审核未通过",3],["审核通过",4],["图片审核失败",5],["文描审核失败",6],["生码中(第一次审核中)",7]]
  enum_attr :is_dup_audit, [["非二次审核",0],["是二次审核",1]],:not_valid => true
  enum_attr :genre,[["普通商品",0],["套餐商品",1],["系列商品",2]]
  scope :with_account, ->(account_id){ where(account_id: account_id) }

  before_save :build_yihaodian_sku


  def build_yihaodian_sku
    self.yihaodian_skus.build(self.attributes.slice(*YihaodianSku.column_names).except(*%w(id created_at updated_at))) if self.genre_0?
  end
end
