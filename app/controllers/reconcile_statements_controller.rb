# encoding: utf-8
class ReconcileStatementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_rs, only: [:show, :audit]

  def index
    # TODO:
      # load default data(eg. last month trade data)
      # load data by filter params[:date]
      # load data by trade store
      # load data by trade store + filter params[:date]
    @rs_set = []
  end

  def show
    # TODO:
      # load details data by params[:id]
    @detail = @rs.detail
  end

  def audit
    # TODO:
      # toggle the column [audited] of reconcile statement to ture/false
    @rs.update_attribute(:audited, true)
    head :ok
  end

  def exports
    # TODO:
      # export the data based on request reconcile statements(params[:selected_rs])
    if params[:selected_rs].blank?
      flash[:error] = "不正确的参数，数据导出失败"
    else
      # send file. eg: CSV or other formats.
      @rs_data = ReconcileStatementDetail.to_xls_file(params[:selected_rs])
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
