class ChangeAuditedInReconcileStatement < ActiveRecord::Migration
  def up
  	change_column :reconcile_statements, :audited, :boolean, default: false
  end

  def down
  	change_column :reconcile_statements, :audited, :boolean
  end
end
