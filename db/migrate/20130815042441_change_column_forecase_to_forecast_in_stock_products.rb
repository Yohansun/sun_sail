class ChangeColumnForecaseToForecastInStockProducts < ActiveRecord::Migration
  def up
    rename_column :stock_products,  :forecase,  :forecast
  end

  def down
    rename_column :stock_products,  :forecast,  :forecase
  end
end
