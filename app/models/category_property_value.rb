class CategoryPropertyValue < ActiveRecord::Base
  attr_accessible :category_property_id, :taobao_id, :value
  
  belongs_to  :category_property
  
end
