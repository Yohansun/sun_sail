class AddColumnForecaseToStockProducts < ActiveRecord::Migration
  def change
    add_column :stock_products,  :forecase,  :integer,   :default => 0
  end
end
