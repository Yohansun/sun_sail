class AddSellerIdIndexToStockProducts < ActiveRecord::Migration
  def change
  	add_column :stock_products, :seller_id, :integer
  	add_index :stock_products, :seller_id
  	add_column :stock_histories, :seller_id, :integer
  	add_index :stock_histories, :seller_id
  end
end
