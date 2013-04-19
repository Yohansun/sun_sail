class AddTaobaoProducts < ActiveRecord::Migration
	def change
		create_table :taobao_products do |t|
			t.integer :category_id
			t.integer :account_id
			t.integer :num_iid
			t.decimal :price
			t.string  :outer_id
			t.string	:product_id		
			t.string  :cat_name  
			t.string  :pic_url
			t.string  :cid
			t.string  :name    
			t.timestamps
		end 
	end
end
