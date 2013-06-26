class NotifyController < ApplicationController
	layout "management"
	respond_to :html, :xls

	def sms
		@start_at = params[:search][:start_at] if params[:search].present?
		@end_at = params[:search][:end_at] if params[:search].present?
		@start_at ||= Time.now.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
		@end_at ||= Time.now.end_of_day.strftime("%Y-%m-%d %H:%M:%S")
		@key_word = params[:search][:key_word] if params[:search].present?
		key_word_condition = []
		key_word_condition << {:notify_sender => /#{@key_word}/}
		key_word_condition << {:notify_contact => /#{@key_word}/}
		key_word_condition << {:notify_theme => /#{@key_word}/}
		key_word_condition << {:notify_content => /#{@key_word}/}
		hash_condition = {}
		hash_condition.update({:created_at.gt => @start_at}) if @start_at.present?
		hash_condition.update({:created_at.lt => @end_at}) if @end_at.present?
		@notifys = Notify.sms(current_account.id).any_of(key_word_condition).where(hash_condition).order_desc
		@number = 20
		@number = params[:number] if params[:number].present?
		@notifies = @notifys.page(params[:page]).per(@number)
		@count = @notifys.count
		respond_with @notifys
	end

	def email
		@start_at = params[:search][:start_at] if params[:search].present?
		@end_at = params[:search][:end_at] if params[:search].present?
		@start_at ||= Time.now.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
		@end_at ||= Time.now.end_of_day.strftime("%Y-%m-%d %H:%M:%S")
		@key_word = params[:search][:key_word] if params[:search].present?
		key_word_condition = []
		key_word_condition << {:notify_sender => /#{@key_word}/}
		key_word_condition << {:notify_contact => /#{@key_word}/}
		key_word_condition << {:notify_theme => /#{@key_word}/}
		key_word_condition << {:notify_content => /#{@key_word}/}
		hash_condition = {}
		hash_condition.update({:created_at.gt => @start_at}) if @start_at.present?
		hash_condition.update({:created_at.lt => @end_at}) if @end_at.present?
		@notifys = Notify.email(current_account.id).any_of(key_word_condition).where(hash_condition).order_desc
		@number = 20
		@number = params[:number] if params[:number].present?
		@notifies = @notifys.page(params[:page]).per(@number)
		@count = @notifys.count
		respond_with @notifys
	end
end
