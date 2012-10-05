class AddStockOpenedAtToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :stock_opened_at, :datetime
  end
end
