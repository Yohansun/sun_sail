class AddExportedToReconcileStatements < ActiveRecord::Migration
  def change
  	add_column :reconcile_statements, :exported, :text
  end
end
