class CreateSkuProducts < ActiveRecord::Migration
  def change
    create_table :sku_product do |t|
      t.integer :sku_id
      t.integer :product_id
      t.integer :number
    end
  end
end