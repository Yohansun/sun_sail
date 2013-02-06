# -*- encoding : utf-8 -*-
class CallcenterController < ApplicationController
	include CallcenterHelper
	before_filter :authenticate_user!
	before_filter :check_module

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
        range_start = Time.now - 30.day
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
				range_start = Time.now - 30.day
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
				range_start = Time.now - 30.day
			end
			range_end = Time.now - 1.day
			@start_date = range_start.beginning_of_day
			@end_date = range_end.end_of_day
		end
		@members = created_and_paid_contrast(@start_date, @end_date)
		@total_info = WangwangMemberContrast.total_created_and_paid(@start_date, @end_date)
	end

	def followed_paid
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
				range_start = Time.now - 30.day
			end
			range_end = Time.now - 1.day
			@start_date = range_start.beginning_of_day
			@end_date = range_end.end_of_day
		end
		@members = followed_paid_contrast(@start_date, @end_date)
		@total_info = WangwangMemberContrast.total_followed_paid(@start_date, @end_date)
	end

  def settings
    @setting = WangwangChatlogSetting.first
    @wangwangs = WangwangMember.all
  end

  def adjust_filter
    @wangwangs = WangwangMember.all
    @setting = WangwangChatlogSetting.first
    @setting.update_attributes(params[:setting])
    if @setting.save
	    start_date = WangwangChatlog.last.start_time.to_date
	    end_date = WangwangChatlog.first.start_time.to_date
	    WangwangDataReprocess.perform_async(start_date, end_date)
	    redirect_to "/callcenter/contrastive_performance"
	  else
	  	redirect_to "/callcenter/settings"
	  end
  end

  def wangwang_list
    @flag = false
    user = WangwangMember.where(_id: params[:u_id]).first
    setting = WangwangChatlogSetting.first
    setting.wangwang_list = setting.wangwang_list.merge(user._id => user.short_id)
    if setting.save
      @flag = true
    else
      @flag = false
    end
    @wangwang_list = setting.wangwang_list
    respond_to do |f|
      f.js
    end
  end

  def remove_wangwang
    user = WangwangMember.where(_id: params[:u_id]).first
    setting = WangwangChatlogSetting.first
    setting.wangwang_list.delete(user._id.to_s)
    setting.wangwang_list = {} if setting.wangwang_list == nil
    setting.save
    respond_to do |f|
      f.js
    end
  end

  private

  def check_module
  	redirect_to "/" if current_account.setting('enable_module_wangwang') != true
  	redirect_to "/" if !current_user.has_role?(:admin)
  end
end