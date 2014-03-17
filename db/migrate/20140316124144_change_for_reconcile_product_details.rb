class ChangeForReconcileProductDetails < ActiveRecord::Migration
  def change
  	change_column :reconcile_product_details, :initial_num, :integer, default: 0
  	change_column :reconcile_product_details, :subtraction, :integer, default: 0
  	change_column :reconcile_product_details, :total_num, :integer, default: 0
  	change_column :reconcile_product_details, :offline_return, :integer, default: 0
  	change_column :reconcile_product_details, :hidden_num, :integer, default: 0
  end
end
