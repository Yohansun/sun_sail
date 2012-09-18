class AddHasStockToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :has_stock, :boolean
  end
end
