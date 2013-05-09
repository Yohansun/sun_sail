class AddCategoryPropertyIdForSkuProperties < ActiveRecord::Migration
  def up
    add_column  :sku_properties,        :category_property_id,      :integer
    add_index   :sku_properties,        :category_property_id
    SkuProperty.all.each{|sp|
        sp.category_property = sp.category_property_value.category_property
        sp.save!
    }
  end

  def down
    remove_column  :sku_properties,        :category_property_id
  end
end
