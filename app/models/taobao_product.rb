# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: taobao_products
#
#  id              :integer(4)      not null, primary key
#  category_id     :integer(4)
#  account_id      :integer(4)
#  num_iid         :integer(8)
#  price           :integer(10)
#  outer_id        :string(255)
#  product_id      :string(255)
#  cat_name        :string(255)
#  pic_url         :string(255)
#  cid             :string(255)
#  name            :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  trade_source_id :integer(4)
#  shop_name       :string(255)
#

class TaobaoProduct < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :taobao_skus, dependent: :destroy
  accepts_nested_attributes_for :taobao_skus, :allow_destroy => true

  attr_protected []
  # add validation

  def has_bindings
    status = "未绑定"
    taobao_skus.each do |sku|
      if sku.sku_bindings.present?
        status = "已绑定"
      else
        status = "部分绑定" and break if status == "已绑定"
      end
    end
    return status
  end
end
