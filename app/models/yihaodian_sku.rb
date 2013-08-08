#encoding: utf-8
class YihaodianSku < ActiveRecord::Base
  include MagicEnum
  attr_accessible :can_sale, :can_show, :category_id, :ean13, :outer_id, :product_cname, :product_code, :product_id
  belongs_to :yihaodian_product, :class_name => "YihaodianProduct", :foreign_key => "product_id"
  validates :product_code,:product_cname ,:presence => true
  enum_attr :can_sale,YihaodianProduct::CAN_SALE
  enum_attr :is_dup_audit, YihaodianProduct::IS_DUP_AUDIT,:not_valid => true
end
