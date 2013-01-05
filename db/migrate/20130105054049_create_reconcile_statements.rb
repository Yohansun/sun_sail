class CreateReconcileStatements < ActiveRecord::Migration
  def change
    create_table :reconcile_statements do |t|
      t.string  :trade_store_source
      t.string  :trade_store_name
      t.integer :balance_amount
      t.boolean :audited
      t.timestamps
    end
    add_index :reconcile_statements, :trade_store_source
    add_index :reconcile_statements, :created_at
  end
end
