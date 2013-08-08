#encoding: utf-8
class YihaodianProduct < ActiveRecord::Base
  include MagicEnum
  attr_accessible :brand_id, :can_sale, :can_show, :category_id, :ean13, :is_dup_audit, :merchant_category_id, :outer_id, :prod_detail_url, :prod_img, :product_cname, :product_code, :product_id, :verify_flg
  validates :product_code,:product_cname ,:presence => true
  has_many :yihaodian_skus, :class_name => "YihaodianSku", :foreign_key => "product_id",:primary_key => "product_id"
  enum_attr :can_sale,[["下架",0],["上架",1]]
  enum_attr :verify_flg,[["新增未审核",1],["编辑待审核",2],["审核未通过",3],["审核通过",4],["图片审核失败",5],["文描审核失败",6],["生码中(第一次审核中)",7]]
  enum_attr :is_dup_audit, [["非二次审核",0],["是二次审核",1]],:not_valid => true
end
