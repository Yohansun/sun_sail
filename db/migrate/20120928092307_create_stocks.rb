class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :name
      t.integer :seller_id
      t.integer :product_count, default: 0
      t.integer :stock_product_id

      t.timestamps
    end
  end
end
