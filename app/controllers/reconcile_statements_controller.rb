# encoding: utf-8
class ReconcileStatementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_rs, only: [:show, :audit]
  before_filter :check_module

  def index
    @trade_sources = current_account.trade_sources
    @rs_set = current_account.reconcile_statements.recently_data.limit(1)
    if params[:date].present?
      @rs_set = current_account.reconcile_statements.by_date(params[:date])
      unless @rs_set.present?
        flash[:notice] = "当月还未生成"
      end
    end
    @is_clearing = true
    if @rs_set.present?
      rs = @rs_set.map &:audited
      rs.each do |r|
        return @is_clearing = r if r == false
      end
    end
  end

  def show
    @detail = @rs.detail
    respond_to do |f|
      f.js
    end
  end

  def audit
    if @rs.update_attribute(:audited, true)
      render :nothing => true, status: 200
    else
      render :nothing => true, status: 304
    end
  end

  def audits
    current_account.reconcile_statements.update_all({:audited => true}, ["id in (?)", params[:rs_ids].split(',')]) if params[:rs_ids].present?
    redirect_to reconcile_statements_url
  end

  def exports
    if params[:selected_rs].blank?
      flash[:error] = "不正确的参数，数据导出失败"
    else
      ids = params[:selected_rs].to_a
      @rs_data = ReconcileStatementDetail.by_ids(ids)
      flash[:notice] = "数据导出成功"
    end

    respond_to do |format|
      format.xls  { redirect_to reconcile_statements_url unless @rs_data.present? }
      format.html { redirect_to reconcile_statements_url }
    end
  end

  private

  def fetch_rs
    @rs = current_account.reconcile_statements.find(params[:id])
  end

  def check_module
    redirect_to "/" and return if TradeSetting.enable_module_reconcile_statements != true
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end
end
