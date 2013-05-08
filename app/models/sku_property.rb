class SkuProperty < ActiveRecord::Base
  attr_accessible :cached_property_name, :cached_property_value, :category_property_value_id

  belongs_to :skus
  belongs_to :category_property_value

  before_save   :cache_name_value



  def text
    cached_property_name + cached_property_value
  end



:private
  def cache_name_value
    self.cached_property_name = self.cached_property_value.category_property.name
    self.cached_property_value = self.cached_property_value.value
  end



end
