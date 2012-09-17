class CreateStockHistories < ActiveRecord::Migration
  def change
    create_table :stock_histories do |t|
      t.string :operation
      t.integer :number
      t.integer :stock_product_id
      t.string :tid
      t.integer :user_id

      t.timestamps
    end
  end
end
