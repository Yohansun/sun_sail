# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: skus
#
#  id              :integer(4)      not null, primary key
#  sku_id          :integer(8)
#  num_iid         :integer(8)
#  properties      :string(255)     default("")
#  properties_name :string(255)     default("")
#  quantity        :integer(4)
#  product_id      :integer(4)
#

class Sku < ActiveRecord::Base
  belongs_to :account
  attr_accessible :num_iid, :properties, :properties_name, :quantity, :sku_id, :taobao_product_id, :account_id,:product_id
  belongs_to :product,:inverse_of => :skus
  has_many :sku_bindings, dependent: :destroy
  has_many :stock_products
  has_many :taobao_skus, through: :sku_bindings
  has_many :properties, class_name: "SkuProperty"

  def title
    "#{product.try(:name)}#{name}"
  end

  def name
    properties.map(&:text) * "|"
  end

  def value
    properties.map(&:cached_property_value) * "|"
  end

  # migrate skus.properties_name to :properties association
  def migrate_taobao_sku_props
    # if not migrated (props != blank && properties = blank)
    if !properties_name.blank? && properties.blank?
      pid,uid,pname,pvalue = properties_name.split(':')

      # may create 3 data : category_property, category_property_value, 
      #  and association between properties and categories

      property_value = CategoryPropertyValue.find_or_create_by_name_value(pname,pvalue)
      property = property_value.category_property

      # association exist ?
      category = product && product.category
      if category
        if !category.category_properties.name_eq(property.name).first
          category.category_properties << property
        end
      end

      self.properties.create(category_property_value:property_value)
    end
  end


end
