# encoding: utf-8

class PropertyValue
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,                       type: String
  field :value,                      type: String
  field :category_property_value_id, type: Integer

  embedded_in :property_memo

end
