class AddSellerIdToReconcileStatement < ActiveRecord::Migration
  def change
    change_column :reconcile_statements, :balance_amount, :float, :default => 0.0
    add_column :reconcile_statements, :seller_id, :integer
    add_column :reconcile_statements, :processed, :boolean, :default => 0
  end
end
