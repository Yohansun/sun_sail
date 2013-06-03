# == Schema Information
#
# Table name: category_property_values
#
#  id                   :integer(4)      not null, primary key
#  category_property_id :integer(4)
#  value                :string(255)
#  taobao_id            :integer(4)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#

class CategoryPropertyValue < ActiveRecord::Base
  attr_accessible :category_property_id, :taobao_id, :value
  
  belongs_to  :category_property

  scope :category_property_id_eq, ->(id){where(["category_property_values.category_property_id = ?", id])}
  scope :value_eq, ->(value){where(["category_property_values.value = ?", value])}



  def self.find_or_create_by_name_value(pname,pvalue)
    pname.strip!
    pvalue.strip!
    # category exist ?
    property = CategoryProperty.name_eq(pname).first
    property = CategoryProperty.create(name:pname,
            status:CategoryProperty::STATUS_ENABLED,
            value_type:CategoryProperty::VALUE_TYPE_SINGLE) if property.nil?


    # value exist ?
    property_value = property.values.value_eq(pvalue).first
    property_value = property.values.create(value:pvalue) if property_value.nil?

    property_value
  end

  
end
