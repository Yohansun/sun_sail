class AddContentToReconcileSellerDetails < ActiveRecord::Migration
  def change
  	add_column :reconcile_seller_details, :buyer_payment, :integer, default: 0
  	add_column :reconcile_seller_details, :preferential, :integer, default: 0
  	add_column :reconcile_seller_details, :buyer_send_postage, :integer, default: 0
  	add_column :reconcile_seller_details, :taobao_deduction, :integer, default: 0
  	add_column :reconcile_seller_details, :credit_deduction, :integer, default: 0
  	add_column :reconcile_seller_details, :rebate_integral, :integer, default: 0
  	add_column :reconcile_seller_details, :actual_pey, :integer, default: 0
  end
end
