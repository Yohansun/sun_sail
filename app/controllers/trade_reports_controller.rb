class TradeReportsController < ApplicationController
	before_filter :authenticate_user!

	def index
		reports = TradeReport
		if current_user.has_role?(:admin)
			reports = reports.all
		else	
			reports = reports.where(user_id: current_user.id)
		end	
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
  	reports = reports.order_by(:performed_at.desc)
		@reports = reports.page params[:page]
	end	

	def show
    send_data open("#{Rails.root}/data/#{params[:id]}.xls").read, :filename => "#{params[:id]}.xls"
  end
end
