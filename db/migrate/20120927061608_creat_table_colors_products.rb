class CreatTableColorsProducts < ActiveRecord::Migration
  def change
  	create_table :colors_products do |t|
  		t.integer :color_id
  		t.integer :product_id
  		t.timestamps
  	end

  	add_index :colors_products, :product_id
  end
end
