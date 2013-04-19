class AddTaobaoProductsProducts < ActiveRecord::Migration
	def change
		create_table :taobao_products_products do |t|
			t.integer :product_id
			t.integer :taobao_product_id
			t.integer :number, default: 1
		end  
	end
end
