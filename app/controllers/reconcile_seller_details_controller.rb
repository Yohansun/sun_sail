# -*- encoding : utf-8 -*-
class ReconcileSellerDetailsController < ApplicationController
  include ReconcileStatementDetailsHelper
  before_filter :check_module

  def change_detail
    statement = ReconcileStatement.find(params[:reconcile_statement_id])
    details = statement.seller_detail
    details.each_with_index do |detail, index|
      base_fee_rate = params[:base_fee_rate][index]
      audit_amount_rate = params[:audit_amount_rate][index]
      special_products_alipay_revenue_rate = params[:special_products_alipay_revenue_rate][index]
      adjust_amount = params[:adjust_amount][index]
      detail.calculate_fees(base_fee_rate, audit_amount_rate, special_products_alipay_revenue_rate, adjust_amount)
    end
    statement.balance_amount = details.map(&:last_audit_amount).sum
    redirect_to seller_index_reconcile_statements_path if statement.save
  end

  private

  def check_module
    redirect_to "/" and return if current_account.settings.enable_module_reconcile_statements != true
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end
end
