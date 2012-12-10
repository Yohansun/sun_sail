class CallcenterController < ApplicationController
	include CallcenterHelper
	before_filter :authenticate_user!

	def contrastive_performance
		if params[:start_date].present? && params[:end_date].present?
			@start_date = params[:start_date].to_time(:local)
			@end_date = params[:end_date].to_time(:local)
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
		total_inquired_today = WangwangChatpeer.where(:date.gte => @start_date, :date.lt => @end_date).map(&:buyer_nick)
		@members = brief_info_contrast(@start_date, @end_date)
		@total_info = WangwangMemberContrast.total_brief_info(@start_date, @end_date)
		@total_paid_payment = TaobaoTrade.only(:buyer_nick, :pay_time, :payment).where(:pay_time.gte => @start_date, :pay_time.lt => @end_date).where(:buyer_nick.in => total_inquired_today).try(:sum, :payment) || 0
	end

	def inquired_and_created
		if params[:start_date].present? && params[:end_date].present?
			@start_date = params[:start_date].to_time(:local)
			@end_date = params[:end_date].to_time(:local)
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
		@members = inquired_and_created_contrast(@start_date, @end_date)
		@total_info = WangwangMemberContrast.total_inquired_and_created(@start_date, @end_date)
	end

	def created_and_paid
		if params[:start_date].present? && params[:end_date].present?
			@start_date = params[:start_date].to_time(:local)
			@end_date = params[:end_date].to_time(:local)
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
		@members = created_and_paid_contrast(@start_date, @end_date)
		@total_info = WangwangMemberContrast.total_created_and_paid(@start_date, @end_date)
	end
end