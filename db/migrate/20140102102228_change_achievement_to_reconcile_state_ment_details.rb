class ChangeAchievementToReconcileStateMentDetails < ActiveRecord::Migration
  def change
  	change_column :reconcile_statement_details, :achievement, :integer, default: 0
  end
end
