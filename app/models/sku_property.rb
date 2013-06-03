# == Schema Information
#
# Table name: sku_properties
#
#  id                         :integer(4)      not null, primary key
#  sku_id                     :integer(4)
#  category_property_value_id :integer(4)
#  cached_property_name       :string(255)
#  cached_property_value      :string(255)
#  created_at                 :datetime        not null
#  updated_at                 :datetime        not null
#  category_property_id       :integer(4)
#

class SkuProperty < ActiveRecord::Base

  attr_accessible :cached_property_name, :cached_property_value,
                   :category_property_value_id, :category_property_value,
                   :category_property,:category_property_id, :sku_id
  belongs_to :sku
  belongs_to :category_property
  belongs_to :category_property_value
  accepts_nested_attributes_for :category_property_value

  before_save   :cache_name_value



  def text
    return nil if category_property_value.nil?
    cached_property_name + " : " + cached_property_value
  end



:private
  def cache_name_value
    if self.category_property.blank? && self.category_property_value.present?
      self.category_property_id = self.category_property_value.try(:category_property_id)
    end
    self.cached_property_name = self.category_property.try(:name)
    self.cached_property_value = self.category_property_value.value if self.category_property_value
  end



end
