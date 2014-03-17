# -*- encoding : utf-8 -*-
class ReconcileProductDetailsController < ApplicationController
  before_filter :fetch_rsd, only: [:show, :export_detail]

  def change_product_details
    @re_s = ReconcileStatement.find(params[:reconcile_statement_id])
    @re_s.product_details.each_with_index do |detail, index|
      @subtraction = params[:reconcile_product_detail][:subtraction][index].to_i
      @offline_return = params[:reconcile_product_detail][:offline_return][index].to_i
      @audit_price = params[:reconcile_product_detail][:audit_price][index].to_i
      detail.update_attributes(subtraction: @subtraction, offline_return: @offline_return, audit_price: @audit_price)
      detail.calculate_fees
    end
    redirect_to seller_index_reconcile_statements_path
  end

  private

  def fetch_rsd
    @rsd = ReconcileStatementDetail.find(params[:id])
  end

end
