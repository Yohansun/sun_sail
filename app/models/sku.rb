# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: skus
#
#  id              :integer(4)      not null, primary key
#  sku_id          :string(255)
#  num_iid         :integer(8)
#  properties      :string(255)     default("")
#  properties_name :string(255)     default("")
#  quantity        :integer(4)
#  product_id      :integer(4)
#  account_id      :integer(4)
#  code            :string(255)
#

class Sku < ActiveRecord::Base
  belongs_to :account
  attr_accessible :num_iid, :properties, :properties_name, :quantity, :sku_id,
       :taobao_product_id, :account_id,:product_id, :sku_properties_attributes,:code
  belongs_to :product,:include => :category ,:inverse_of => :skus
  has_many :sku_bindings, dependent: :destroy
  has_many :stock_products
  has_many :taobao_skus, through: :sku_bindings
  has_many :sku_properties,  :dependent=>:destroy
  accepts_nested_attributes_for :sku_properties

  has_one :category, through: :product


  after_save  :migrate_taobao_sku_props

  def title
    "#{product.try(:name)}#{name}"
  end

  def title_with_product_id
    title << (product.blank? ? "" : " [#{product.outer_id}] ")
  end

  def name
    sku_properties.map(&:text) * "|"
  end

  def value
     if values_name * "|" == ""
       "默认"
     else
       values_name * "|"
     end
  end

  def values_name
    sku_properties.map(&:cached_property_value)
  end

  def stock_product_ids
    StockProduct.where(product_id: self.product.id, sku_id: self.id).map(&:id)
  end

  # migrate skus.properties_name to :sku_properties association
  def migrate_taobao_sku_props
    # if not migrated (props != blank && properties = blank)
    if !properties_name.blank? && sku_properties.blank?
      props = properties_name.split(';')
      props.each{|prop|
        pid,uid,pname,pvalue = prop.split(':')

        # may create 4 data : category_property, category_property_value,
        #  and association between properties and categories
        #  and sku_properties

        property_value = CategoryPropertyValue.find_or_create_by_name_value(account_id, pname, pvalue)
        property = property_value.category_property

        # association exist ?
        category = product && product.category
        if category
          if !category.category_properties.name_eq(property.name).first
            category.category_properties << property
          end
        end

        self.sku_properties.create(account_id: account_id, category_property_value:property_value, category_property:property)
      }
    end
  end


end
