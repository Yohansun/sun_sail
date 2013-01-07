class AddAuditTimeToReconcileStatement < ActiveRecord::Migration
  def change
  	add_column :reconcile_statements, :audit_time, :datetime
  end
end
