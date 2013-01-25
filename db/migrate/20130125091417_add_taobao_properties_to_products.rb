class AddTaobaoPropertiesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cat_name, :string
    add_column :products, :props_str, :text
    add_column :products, :binds_str, :text
  end
end
