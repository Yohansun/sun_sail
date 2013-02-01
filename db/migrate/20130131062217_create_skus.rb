class CreateSkus < ActiveRecord::Migration
  def change
    create_table :skus do |t|
      t.integer :sku_id, :limit => 8
      t.integer :num_iid, :limit => 8
      t.string :properties, :default => ''
      t.string :properties_name, :default => ''
      t.integer :quantity
    end
  end
end
