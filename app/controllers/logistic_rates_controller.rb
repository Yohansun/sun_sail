# -*- encoding : utf-8 -*-
class LogisticRatesController < ApplicationController
	before_filter :authenticate_user!
	def index
    @rates = current_account.logistic_rates.group(:seller_id, :logistic_id)
    if params[:start_date].present? && params[:end_date].present?
      @start_date = params[:start_date].to_time(form = :local)
      @end_date = params[:end_date].to_time(form = :local).end_of_day
    end
    if params[:seller_id].present? && params[:seller_id] != "all"
      @rates = @rates.where(:seller_id => params[:seller_id])
    end    
    @start_date ||= Time.now - 1.month
    @end_date ||= Time.now
    @rates = @rates.page(params[:page])                                    
  end
end
