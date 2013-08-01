class AddResourceIdToSkuBindings < ActiveRecord::Migration
  def change
    add_column :sku_bindings,:resource_id,:integer
    add_column :sku_bindings,:resource_type,:integer
  end
end
