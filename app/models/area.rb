class Area < ActiveRecord::Base
	acts_as_nested_set
  attr_accessible :parent_id, :name, :is_1568
end
