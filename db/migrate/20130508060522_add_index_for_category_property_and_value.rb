class AddIndexForCategoryPropertyAndValue < ActiveRecord::Migration
  def up
    add_index :category_properties,     :name
    add_index :category_property_values,        :value
  end

  def down
    remove_index :category_properties,     :name
    remove_index :category_property_values,        :value
  end
end
