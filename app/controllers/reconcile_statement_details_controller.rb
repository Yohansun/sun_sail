# -*- encoding : utf-8 -*-
class ReconcileStatementDetailsController < ApplicationController
  include ReconcileStatementDetailsHelper
  before_filter :fetch_rsd, only: [:show, :export_detail]
  before_filter :check_module

  def show
    @trade_details = @rsd.select_trades(params[:page])
    @money_type = params[:money_type]
    @rs = @rsd.reconcile_statement
	end

  def export_detail
    @money_type = params[:money_type]
    @rs = ReconcileStatement.find(@rsd.reconcile_statement_id)
    @file_name = "#{Rails.root}/public/system/#{@rs.audit_time.strftime('%Y-%m') +'-'+ money_type_text(@money_type)}.xls"
    if @rs.exported["#{@money_type}".to_sym]
      send_file @file_name and return
    else
      ReconcileStatementDetailReporter.perform_async(@rsd.id, @money_type)
      redirect_to :back, notice: "正在生成报表，五分钟后请再次点击导出数据下载报表"
    end
  end

  def change_detail
    detail = ReconcileStatementDetail.find(params[:id])
    detail.update_attributes(params[:reconcile_statement_detail])
    params[:store_name] ? detail.calculate_fees(params[:store_name]) : detail.calculate_fees
    redirect_to reconcile_statements_path
  end

  private

  def fetch_rsd
    @rsd = ReconcileStatementDetail.find(params[:id])
  end

  def check_module
    redirect_to "/" and return if current_account.settings.enable_module_reconcile_statements != true
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end
end
