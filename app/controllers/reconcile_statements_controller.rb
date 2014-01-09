# encoding: utf-8
class ReconcileStatementsController < ApplicationController
  before_filter :fetch_rs, only: [:show, :audit, :seller_show]
  before_filter :check_module
  AllActions = {:index => "运营商对账",:seller_index => "经销商对账",:distributor_index => "分销商对账"}

  def index
    @trade_sources = current_account.trade_sources
    @rs_set = current_account.reconcile_statements.where(seller_id: nil).recently_data
    if params[:status].present?
      @rs_set = @rs_set.select_status(params[:status])
    end
    if params[:date].present?
      @rs_set = @rs_set.where(seller_id: nil).by_date(params[:date])
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    end
    if params[:trade_source]
      @rs_set = @rs_set.where(trade_store_name: params[:trade_source]) rescue nil
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    end
    @all_audited = @rs_set.all_audited?
    @all_processed = @rs_set.all_processed?
  end

  def show
    if @rs
      @detail = @rs.detail
      respond_to do |f|
        f.js
      end
    end
  end

  def seller_show
    if @rs
      @details = @rs.seller_detail
      respond_to do |f|
        f.js
      end
    end
  end

  def distributor_show
    if @rs
      @detail = @rs.detail
      respond_to do |f|
        f.js
      end
    end
  end

  def seller_index
    @rs_set = current_account.reconcile_statements.where("seller_id > 0").recently_data
    if params[:status].present?
      @rs_set = @rs_set.select_status(params[:status])
    end
    if params[:date].present?
      @rs_set = @rs_set.by_date(params[:date]) rescue nil
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    end
    if params[:seller_name].present?
      seller_ids = current_account.sellers.where("name like ?", "%#{params[:seller_name].strip}%").map(&:id)
      @rs_set = @rs_set.by_seller_ids(seller_ids) rescue nil
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    end
    @all_processed = @rs_set.all_processed?
    render seller_index_reconcile_statements_path
  end
  
  def audit
    unless @rs.processed
      update_status({:processed => true}, @rs)
    else
      update_status({:audited => true}, @rs)
    end
  end

  def seller_exports
    if params[:selected_rs].blank?
      flash[:error] = "不正确的参数，数据导出失败"
    else
      ids = params[:selected_rs].to_a
      @rs_data = ReconcileSellerDetail.by_ids(ids)
      flash[:notice] = "数据导出成功"
    end

    respond_to do |format|
      format.xls  { redirect_to :back unless @rs_data.present? }
      format.html { redirect_to :back }
    end
  end

  def distributor_exports
    if params[:selected_rs].blank?
      flash[:error] = "不正确的参数，数据导出失败"
    else
      ids = params[:selected_rs].to_a
      @rs_data = ReconcileSellerDetail.by_ids(ids)
      flash[:notice] = "数据导出成功"
    end

    respond_to do |format|
      format.xls  { redirect_to :back unless @rs_data.present? }
      format.html { redirect_to :back }
    end
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

  def distributor_index
    @trade_sources = current_account.trade_sources
    @rs_set = current_account.reconcile_statements.where("trade_source_id > 0").recently_data
    if params[:status].present?
      @rs_set = @rs_set.select_status(params[:status])
    end
    if params[:date].present?
      @rs_set = @rs_set.where(seller_id: nil).by_date(params[:date])
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    end
    if params[:trade_store_source]
      @rs_set = @rs_set.where("trade_store_source like ?", "%#{params[:trade_store_source].strip}%") rescue nil
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    end
    @all_processed = @rs_set.all_processed?
    render distributor_index_reconcile_statements_path
  end

  private

  def fetch_rs
    @rs = current_account.reconcile_statements.find(params[:id])
  end

  def update_status(option={}, statement)
    if statement.update_attributes(option)
      render :nothing => true, status: 200
    else
      render :nothing => true, status: 304
    end
  end

  def check_module
    redirect_to "/" and return if current_account.settings.enable_module_reconcile_statements != true
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end
end