# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: taobao_products
#
#  id          :integer(4)      not null, primary key
#  category_id :integer(4)
#  account_id  :integer(4)
#  num_iid     :integer(8)
#  price       :integer(10)
#  outer_id    :string(255)
#  product_id  :string(255)
#  cat_name    :string(255)
#  pic_url     :string(255)
#  cid         :string(255)
#  name        :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class TaobaoProduct < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :taobao_skus, dependent: :destroy
  accepts_nested_attributes_for :taobao_skus, :allow_destroy => true

  attr_accessible :name, :product_id, :outer_id, :price, :pic_url, :category_id, :cat_name, :detail_url, :num_iid, :cid, :account_id,:sku_id,:taobao_skus_attributes
  # add validation

  def has_bindings
    taobao_skus.each do |sku|
      if sku.sku_bindings.present? && sku.sku_bindings != []
        return "已绑定"
        break
      end
    end
    return "未绑定"
  end
end
