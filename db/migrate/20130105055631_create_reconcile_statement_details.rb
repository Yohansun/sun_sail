class CreateReconcileStatementDetails < ActiveRecord::Migration
  def change
    create_table :reconcile_statement_details do |t|
      t.integer :reconcile_statement_id
      t.integer :alipay_revenue, default: 0
      t.integer :postfee_revenue, default: 0
      t.integer :trade_success_refund, default: 0
      t.integer :sell_refund, default: 0
      t.integer :base_service_fee, default: 0
      t.integer :store_service_award, default: 0
      t.integer :staff_award, default: 0
      t.integer :taobao_cost, default: 0
      t.integer :audit_cost, default: 0
      t.integer :collecting_postfee, default: 0
      t.integer :audit_amount, default: 0
      t.integer :adjust_amount, default: 0
      t.timestamps
    end
    add_index :reconcile_statement_details, :reconcile_statement_id
  end
end
