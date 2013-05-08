class CreateSkuProperties < ActiveRecord::Migration
  def change
    create_table :sku_properties do |t|
      t.integer :sku_id
      t.integer :category_property_value_id
      t.string :cached_property_name
      t.string :cached_property_value

      t.timestamps
    end
    add_index   :sku_properties,   :sku_id
    add_index   :sku_properties,   :category_property_value_id
    Sku.all.each{|sku|
        props = sku.migrate_taobao_sku_props
    }
  end
end
