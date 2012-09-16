class AddActivityToStockProducts < ActiveRecord::Migration
  def change
    add_column :stock_products, :activity, :integer, default: 0
    add_column :stock_products, :actual, :integer, default: 0
  end
end
