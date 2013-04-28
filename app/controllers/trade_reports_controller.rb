class TradeReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize

  def index
    reports = TradeReport.where(account_id: current_account.id)
    reports = reports.where(user_id: current_user.id) unless current_user.has_role?(:admin)
    @start_date = params[:start_date] if params[:start_date].present?
    @end_date =  params[:end_date] if params[:end_date].present?
    @start_time = params[:start_time] if params[:start_time].present?
    @end_time =  params[:end_time] if params[:end_time].present?
    if @start_date && @end_date && @start_time && @end_time
      start_at = "#{@start_date} #{@start_time}".to_time(form = :local)
      end_at = "#{@end_date} #{@end_time}".to_time(form = :local)
      reports = reports.where(:performed_at.gte => start_at, :performed_at.lte => end_at)
    else
      @start_date = @end_date = @start_time = @end_time = ''
    end 
    reports = reports.order_by(:request_at.desc)
    @reports = reports.page params[:page]
  end 

  def download
    send_data open("#{Rails.root}/data/#{params[:id]}.xls").read, :filename => "#{params[:id]}.xls"
  end
end
