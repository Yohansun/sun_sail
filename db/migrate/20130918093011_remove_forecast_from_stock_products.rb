class RemoveForecastFromStockProducts < ActiveRecord::Migration
  def up
    remove_column :stock_products,  :forecast
  end

  def down
    add_column :stock_products,  :forecast
  end
end
