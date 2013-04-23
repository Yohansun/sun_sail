class CreateSkuBindings < ActiveRecord::Migration
  def change
    create_table :sku_bindings do |t|
    	t.integer :sku_id, :limit => 8
      t.integer :taobao_sku_id, :limit => 8
      t.integer :number, :limit => 8
    end
  end
end
