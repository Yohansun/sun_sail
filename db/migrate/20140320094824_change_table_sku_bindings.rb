class ChangeTableSkuBindings < ActiveRecord::Migration
  def change
    change_table(:sku_bindings) do |t|
      t.timestamps
    end
  end
end