class CallcenterController < ApplicationController
	before_filter :authenticate_user!
	def contrastive_performance
		if params[:start_date].present? && params[:end_date].present?
			@start_date = params[:start_date].to_time(form = :local)
			@end_date = params[:end_date].to_time(form = :local)
		else	
			if params[:date_range].present?
				 if params[:date_range] == "lastest_week"
					range_start = Time.now - 1.week + 1.day if params[:date_range] == "lastest_week"
				elsif params[:date_range] == "lastest_month"
				  range_start = Time.now - 1.month + 1.day	
				end	
			else	
        range_start = Time.now - 1.day
			end	
			range_end = Time.now - 1.day
			@start_date = range_start.beginning_of_day
			@end_date = range_end.end_of_day
		end
		@members = WangwangMember.all

		@option = "receivenum"
	end

	def switch_option
		if params[:option].present?
			@option = params[:option]
	    respond_to do |f|
	      f.js
	    end
	  else
	  	render nothing: true
	  end	  
	end	

end
