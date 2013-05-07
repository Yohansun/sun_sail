# -*- encoding : utf-8 -*-
class CreateCategoryPropertyValues < ActiveRecord::Migration
  def change
    create_table :category_property_values do |t|
      t.integer :category_property_id
      t.string :value
      t.integer :taobao_id

      t.timestamps
      
    end
    add_index :category_property_values, :category_property_id
    add_index :category_property_values, :taobao_id
  end
end
