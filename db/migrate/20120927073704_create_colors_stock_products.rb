class CreateColorsStockProducts < ActiveRecord::Migration
  def change
  	create_table :colors_stock_products do |t|
  		t.integer :color_id
  		t.integer :stock_product_id
  	end

  	add_index :colors_stock_products, :stock_product_id
  end
end
