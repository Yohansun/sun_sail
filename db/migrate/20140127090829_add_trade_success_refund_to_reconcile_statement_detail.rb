class AddTradeSuccessRefundToReconcileStatementDetail < ActiveRecord::Migration
  def change
  	add_column :reconcile_statement_details, :credit_card_money, :integer, default: 0
  	add_column :reconcile_statement_details, :sale_commission, :integer, default: 0
  	add_column :reconcile_statement_details, :return_point_money, :integer, default: 0
  	add_column :reconcile_statement_details, :other_point_money, :integer, default: 0
  	add_column :reconcile_statement_details, :handmade_trade_money, :integer, default: 0
  	add_column :reconcile_statement_details, :memo, :string, limit: 500
  end
end
