class AddAccountIdForStockProducts < ActiveRecord::Migration
  def up
    add_column :stock_products, :account_id, :integer
    add_column :features, :account_id, :integer
    add_column :quantities, :account_id, :integer
    add_column :reconcile_statements, :account_id, :integer
    add_column :logistics, :account_id, :integer
    add_column :logistic_rates, :account_id, :integer
    add_column :logistic_areas, :account_id, :integer
  end

  def down
    remove_column :stock_products, :account_id
    remove_column :features, :account_id
    remove_column :quantities, :account_id
    remove_column :reconcile_statements, :account_id
    remove_column :logistics, :account_id
    remove_column :logistic_rates, :account_id
    remove_column :logistic_areas, :account_id
  end
end
