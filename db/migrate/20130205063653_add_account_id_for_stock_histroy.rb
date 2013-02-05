class AddAccountIdForStockHistroy < ActiveRecord::Migration
  def up
    add_column :stock_histories, :account_id, :integer
  end

  def down
    remove_column :stock_histories, :account_id
  end
end
