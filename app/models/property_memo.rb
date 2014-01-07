# encoding: utf-8

class PropertyMemo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :account_id,        type: Integer
  field :outer_id,          type: String

  embeds_many :property_values

  index account_id: 1
  index outer_id: 1
  index "property_values.category_property_value_id" => 1
  index "property_values.value" => 1

end