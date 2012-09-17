class AddMaxToStockProducts < ActiveRecord::Migration
  def change
    add_column :stock_products, :max, :integer, default: 0
    add_column :stock_products, :safe_value, :integer, default: 0
  end
end
