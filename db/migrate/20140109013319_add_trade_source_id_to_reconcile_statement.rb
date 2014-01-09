class AddTradeSourceIdToReconcileStatement < ActiveRecord::Migration
  def change
  	add_column :reconcile_statements, :trade_source_id, :string
  end
end
