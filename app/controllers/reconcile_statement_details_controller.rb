# -*- encoding : utf-8 -*-
class ReconcileStatementDetailsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :fetch_rsd, only: [:show]
	def show
    @trade_details = @rsd.select_trades(params[:page])
    @money_type = params[:money_type]
	end

	private

  def fetch_rsd
    @rsd = ReconcileStatementDetail.find(params[:id])
  end
end
