class RemoveIidFromStockProducts < ActiveRecord::Migration
  def up
    remove_column :stock_products, :iid
    remove_column :stock_products, :name
    remove_column :stock_products, :taobao_id
    remove_column :stock_products, :status
    remove_column :stock_products, :descript
    remove_column :stock_products, :category
    add_column :stock_products, :product_id, :integer
  end

  def down
    remove_column :stock_products, :product_id
    add_column :stock_products, :taobao_id, :string
    add_column :stock_products, :category, :string
    add_column :stock_products, :descript, :string
    add_column :stock_products, :status, :string
    add_column :stock_products, :name, :string
    add_column :stock_products, :iid, :integer
  end
end
