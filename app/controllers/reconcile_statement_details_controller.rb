# -*- encoding : utf-8 -*-
class ReconcileStatementDetailsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_rsd, only: [:show]
  before_filter :check_module
  def show
    @trade_details = @rsd.select_trades(params[:page])
    @money_type = params[:money_type]
  end

  private

  def fetch_rsd
    @rsd = ReconcileStatementDetail.find(params[:id])
  end

  def check_module
    redirect_to "/" and return if TradeSetting.enable_module_reconcile_statements != true
    redirect_to "/" and return if !current_user.has_role?(:admin)
  end
end
