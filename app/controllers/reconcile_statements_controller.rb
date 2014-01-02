# encoding: utf-8
class ReconcileStatementsController < ApplicationController
  before_filter :fetch_rs, only: [:show, :audit]
  before_filter :check_module
  AllActions = {:index => "运营商对账",:seller_index => "经销商对账"}

  def index
    @trade_sources = TradeSource.all
    @rs_set = current_account.reconcile_statements.where(seller_id: nil).recently_data
    status = {unprocessed: false, processed: true, unaudited: false, audited: true}
    if params[:status]
      status.each.find do |key, value|
        if params[:status] == key
          status_key = key.gsub("un", "")
          @rs_set = @rs_set.where(status_key: value)
        end
      end
    end
    if params[:date].present?
      @rs_set = @rs_set.where(seller_id: nil).by_date(params[:date])
      unless @rs_set.present?
        flash[:notice] = "当月还未生成"
      end
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

  def seller_index
    @trade_sources = TradeSource.all
    if current_user.has_role?(:seller)
      @rs_set = current_account.reconcile_statements.where(processed: true, seller_id: current_user.seller_id)
    elsif current_user.has_role?(:admin)
      @rs_set = current_account.reconcile_statements.where("seller_id > 0")
    end
    if params[:status]
      if params[:status] == "unprocessed"
        @rs_set = @rs_set.where(processed: false)
      elsif params[:status] == "processed"
        @rs_set = @rs_set.where(processed: true, audited: false)
      elsif params[:status] == "unaudited"
        @rs_set = @rs_set.where(audited: false)
      elsif params[:status] == "audited"
        @rs_set = @rs_set.where(audited: true)
      else
        @rs_set = @rs_set
      end
    end
    if params[:date].present?
      @rs_set = @rs_set.by_date(params[:date]) rescue nil
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    else
      @rs_set = @rs_set
    end
    if params[:seller_name].present?
      seller_ids = current_account.sellers.where("name like ?", "%#{params[:seller_name].strip}%").map(&:id)
      @rs_set = @rs_set.where("seller_id in (?)", seller_ids) rescue nil
      flash[:notice] = "当月还未生成" unless @rs_set.present?
    else
      @rs_set = @rs_set
    end
    @all_audited = true
    @all_audited = @rs_set.all_audited? if @rs_set.respond_to?(:all_audited?)
    render seller_index_reconcile_statements_path
  end

  def audit
    unless @rs.processed
      if @rs.update_attribute(:processed, true)
        render :nothing => true, status: 200
      else
        render :nothing => true, status: 304
      end
    else
      if @rs.update_attribute(:audited, true)
        render :nothing => true, status: 200
      else
        render :nothing => true, status: 304
      end
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

  def process_all
    current_account.reconcile_statements.update_all({:processed => true}, ["id in (?)", params[:rs_ids].split(',')]) if params[:rs_ids].present?
    redirect_to :back
  end

  private

  def fetch_rs
    @rs = current_account.reconcile_statements.find(params[:id])
  end

  def check_module
    redirect_to "/" and return if current_account.settings.enable_module_reconcile_statements != true
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end
end
