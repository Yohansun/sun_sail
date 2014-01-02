class AddSpecialProductDetailToReconcileStatementDetail < ActiveRecord::Migration
  def change
    add_column :reconcile_statement_details, :special_products_alipay_revenue, :integer, default: 0
    add_column :reconcile_statement_details, :special_products_audit_amount, :integer, default: 0
    add_column :reconcile_statement_details, :base_fee, :integer, default: 0
    add_column :reconcile_statement_details, :last_audit_amount, :integer, default: 0
    add_column :reconcile_statement_details, :account_profit, :integer, default: 0
    add_column :reconcile_statement_details, :advertise_reserved, :integer, default: 0
    add_column :reconcile_statement_details, :platform_deduction, :integer, default: 0
  end
end
