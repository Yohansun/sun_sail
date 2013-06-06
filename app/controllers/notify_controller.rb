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

		@notifies = Notify.sms(current_account.id).any_of(key_word_condition).where(hash_condition).order_desc.page(params[:page])
		@count = Notify.sms(current_account.id).any_of(key_word_condition).where(hash_condition).count

		respond_with @notifies
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

		@notifies = Notify.email(current_account.id).any_of(key_word_condition).where(hash_condition).order_desc.page(params[:page])
		@count = Notify.email(current_account.id).any_of(key_word_condition).where(hash_condition).count

		respond_with @notifies
  end
end
