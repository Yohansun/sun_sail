class CreateReconcileProductDetail < ActiveRecord::Migration
  def change
  	create_table :reconcile_product_details do |t|
      t.string  :name
      t.string  :outer_id                      
      t.integer :reconcile_statement_id          
      t.integer :initial_num 
      t.integer :subtraction
      t.integer :total_num
      t.float   :last_month_num
      t.integer :product_id
      t.integer :offline_return
      t.integer :hidden_num
      t.integer :seller_id

      t.timestamps
    end
    add_index :reconcile_product_details, :outer_id
  end
end
