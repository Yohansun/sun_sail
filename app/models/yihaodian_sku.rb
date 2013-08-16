#encoding: utf-8
class YihaodianSku < ActiveRecord::Base
  include MagicEnum
  attr_protected []
  has_many :sku_bindings,:include => :sku, dependent: :destroy,:conditions => {:resource_type => "YihaodianSku"},:foreign_key => :resource_id
  has_many :skus,:include => :product, through: :sku_bindings
  belongs_to :yihaodian_product, :class_name => "YihaodianProduct", :foreign_key => "parent_product_id",:primary_key => "product_id"
  validates :product_code,:product_cname ,:presence => true
  enum_attr :can_sale,YihaodianProduct::CAN_SALE
  enum_attr :is_dup_audit, YihaodianProduct::IS_DUP_AUDIT,:not_valid => true
  scope :with_account, ->(account_id){ where(account_id: account_id) }
end
