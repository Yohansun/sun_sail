class CreateReconcileStatementDetails < ActiveRecord::Migration
  def change
    create_table :reconcile_statement_details do |t|
      t.integer :reconcile_statement_id
      t.integer :alipay_revenue
      t.integer :postfee_revenue
      t.integer :trade_success_refund
      t.integer :sell_refund
      t.integer :base_service_fee
      t.integer :store_service_award
      t.integer :staff_award
      t.integer :taobao_cost
      t.integer :audit_cost
      t.integer :collecting_postfee
      t.integer :audit_amount
      t.integer :adjust_amount
      t.timestamps
    end
    add_index :reconcile_statement_details, :reconcile_statement_id
  end
end
