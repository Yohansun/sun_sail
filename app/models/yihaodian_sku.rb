#encoding: utf-8
# == Schema Information
#
# Table name: yihaodian_skus
#
#  id                :integer(4)      not null, primary key
#  product_code      :string(255)     not null
#  product_cname     :string(255)     not null
#  product_id        :integer(8)
#  ean13             :string(255)
#  category_id       :integer(8)
#  can_sale          :integer(4)
#  outer_id          :string(255)
#  can_show          :integer(4)
#  account_id        :integer(4)
#  parent_product_id :integer(8)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  trade_source_id   :integer(4)
#  shop_name         :string(255)
#

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
  scope :is_binding, includes(:sku_bindings).where("sku_bindings.id is not null")
  scope :no_binding, includes(:sku_bindings).where("sku_bindings.id is null")

  has_paper_trail

  def title
    "#{yihaodian_product.try(:product_cname)}"
  end

end
