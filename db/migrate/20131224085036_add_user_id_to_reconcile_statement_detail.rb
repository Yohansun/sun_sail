class AddUserIdToReconcileStatementDetail < ActiveRecord::Migration
  def change
    add_column :reconcile_statement_details, :special_products_alipay_revenue, :integer, default: 0
    add_column :reconcile_statement_details, :special_products_audit_amount, :integer, default: 0
    add_column :reconcile_statement_details, :base_fee, :integer, default: 0
    add_column :reconcile_statement_details, :last_audit_amount, :integer, default: 0
    add_column :reconcile_statement_details, :account_profit, :integer, default: 0
    add_column :reconcile_statement_details, :advertise_reserved, :integer, default: 0
    add_column :reconcile_statement_details, :platform_deduction, :integer, default: 0
    add_column :reconcile_statement_details, :base_fee_percent, :integer, default: 5             
    add_column :reconcile_statement_details, :special_products_audit_amount_percent, :integer, default: 5                               
    add_column :reconcile_statement_details, :audit_amount_percent, :integer, default: 5                               
    add_column :reconcile_statement_details, :account_profit_percent_a, :integer, default: 5                           
    add_column :reconcile_statement_details, :account_profit_percent_b, :integer, default: 5                           
    add_column :reconcile_statement_details, :account_profit_percent_c, :integer, default: 5                           
    add_column :reconcile_statement_details, :advertise_reserved_percent_a, :integer, default: 5                       
    add_column :reconcile_statement_details, :advertise_reserved_percent_b, :integer, default: 5                       
    add_column :reconcile_statement_details, :platform_deduction_percent_a, :integer, default: 5                       
    add_column :reconcile_statement_details, :platform_deduction_percent_b, :integer, default: 5                       
    add_column :reconcile_statement_details, :user_id, :integer
    add_column :reconcile_statement_details, :achievement, :integer
  end
end
