class CreateStockProducts < ActiveRecord::Migration
  def change
    create_table :stock_products do |t|
      t.integer :iid
      t.string :name
      t.integer :taobao_id
      t.string :status
      t.text :descript
      t.string :category

      t.timestamps
    end
  end
end
