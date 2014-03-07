#encoding: utf-8
# == Schema Information
#
# Table name: yihaodian_products
#
#  id                   :integer(4)      not null, primary key
#  product_code         :string(255)     not null
#  product_cname        :string(255)     not null
#  product_id           :integer(8)
#  ean13                :string(255)
#  category_id          :integer(8)
#  can_sale             :integer(4)
#  outer_id             :string(255)
#  can_show             :integer(4)
#  verify_flg           :integer(4)
#  is_dup_audit         :integer(4)
#  prod_img             :text
#  prod_detail_url      :string(255)
#  brand_id             :integer(8)
#  merchant_category_id :string(255)
#  genre                :integer(4)
#  account_id           :integer(4)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  trade_source_id      :integer(4)
#  shop_name            :string(255)
#

class YihaodianProduct < ActiveRecord::Base
  include MagicEnum
  attr_protected []
  validates :product_code,:product_cname ,:presence => true
  has_many :yihaodian_skus, :class_name => "YihaodianSku", :foreign_key => "parent_product_id",:primary_key => "product_id",:dependent => :destroy
  enum_attr :can_sale,[["下架",0],["上架",1]]
  enum_attr :verify_flg,[["新增未审核",1],["编辑待审核",2],["审核未通过",3],["审核通过",4],["图片审核失败",5],["文描审核失败",6],["生码中(第一次审核中)",7]]
  enum_attr :is_dup_audit, [["非二次审核",0],["是二次审核",1]],:not_valid => true
  enum_attr :genre,[["普通商品",0],["套餐商品",1],["系列商品",2]]
  scope :with_account, ->(account_id){ where(account_id: account_id) }

  has_paper_trail

  before_create :build_yihaodian_sku

  def has_bindings
    status = "未绑定"
    yihaodian_skus.each do |sku|
      if sku.sku_bindings.present?
        status = "已绑定"
      else
        status = "部分绑定" and break if status == "已绑定"
      end
    end
    return status
  end

  def build_yihaodian_sku
    attrs = self.attributes.slice(*YihaodianSku.column_names).except(*%w(id created_at updated_at))
    self.yihaodian_skus.build(attrs) if self.genre_0?
  end
end
