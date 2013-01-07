# encoding: utf-8
class ReconcileStatementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_rs, only: [:show, :audit]

  def index
    @trade_sources = TradeSource.all
    @rs_set = ReconcileStatement.get_last_month
    if params[:date].present?
      @rs_set = ReconcileStatement.by_date(params[:date])
      unless @rs_set.present?
        flash[:notice] = "当月还未生成"
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

  def exports
    if params[:selected_rs].blank?
      flash[:error] = "不正确的参数，数据导出失败"
    else
      @rs_data = ReconcileStatementDetail.by_ids(params[:selected_rs])
      flash[:notice] = "数据导出成功"
    end

    respond_to do |format|
      format.xls  { redirect_to reconcile_statements_url unless @rsd.present? }
      format.html { redirect_to reconcile_statements_url }
    end
  end

  private

  def fetch_rs
    @rs = ReconcileStatement.find(params[:id])
  end
end
