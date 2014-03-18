class AddReconcileProductDetail < ActiveRecord::Migration
  def change
  	add_column :reconcile_product_details, :sell_price, :integer, default: 0
  end
end
