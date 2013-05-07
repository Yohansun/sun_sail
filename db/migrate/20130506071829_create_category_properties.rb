# -*- encoding : utf-8 -*-
class CreateCategoryProperties < ActiveRecord::Migration
  def change
    create_table :category_properties do |t|
      t.string :name
      t.integer :value_type
      t.integer :taobao_id
      t.integer :status
      t.timestamps
      
    end
    add_index :category_properties, :status

    create_table :categories_category_properties, :id => false do |t|
      t.integer :category_id
      t.integer :category_property_id
    end

    add_index   :categories_category_properties,    :category_id
    add_index   :categories_category_properties,    :category_property_id
  end
end
