class AddAuditPriceToReconcileProductDetails < ActiveRecord::Migration
  def change
  	add_column :reconcile_product_details, :audit_num, :integer, default: 0
  	add_column :reconcile_product_details, :audit_price, :integer, default: 0

  end
end
