#encoding: utf-8
class YihaodianSku < ActiveRecord::Base
  include MagicEnum
  attr_protected []
  belongs_to :yihaodian_product, :class_name => "YihaodianProduct", :foreign_key => "product_id"
  validates :product_code,:product_cname ,:presence => true
  enum_attr :can_sale,YihaodianProduct::CAN_SALE
  enum_attr :is_dup_audit, YihaodianProduct::IS_DUP_AUDIT,:not_valid => true
end
