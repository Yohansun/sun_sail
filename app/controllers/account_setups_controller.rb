# -*- encoding:utf-8 -*-
class AccountSetupsController < ApplicationController
  include Wicked::Wizard
  layout  "management"
  before_filter :check_account_wizard_status, only:[:show]

  skip_before_filter :verify_authenticity_token, only: [:data_fetch_finish]
#  before_filter :authorize,:only => [:edit_preprocess_settings, :update_preprocess_settings,
#                                                      :edit_dispatch_settings, :update_dispatch_settings,
#                                                      :edit_deliver_settings, :update_deliver_settings]

  skip_before_filter :authenticate_user!, if: proc{|c| c.current_account && c.current_user.nil?}
  steps :admin_init, :data_fetch, :options_setup, :user_init

  def show
    (redirect_to root_path; return) if current_account.settings[:wizard_step] == :finish
    Rails.logger.debug "account setup ::: #{current_account.inspect}"
    render_wizard
  end

  def update
    next_step_name = next_step
    case step
    when :admin_init
      @user = User.new(params[:user])
      @user.accounts << current_account
      @user.password = SecureRandom.hex(3)
      (render_wizard; return) if !@user.save

      @user.add_role(:admin)

      InitUserNotifier.perform_async(current_account.id, @user.email, @user.password, @user.phone)

      current_account.settings[:wizard_step] = ""
      if params[:init_finished].present?
        next_step_name = :finish
        current_account.settings.init_data_ready = false
        current_account.settings.auto_settings = {'split_conditions' => {},
                                          'dispatch_conditions'=>{},
                                          'unusual_conditions'=>{},
                                          'auto_deliver' => nil,
                                          'auto_dispatch' => nil}
      else
        current_account.settings[:wizard_step] = next_step_name
      end
      sign_in @user # auto login after create admin user
    when :options_setup
      current_account.settings.auto_settings = {'split_conditions' => {}, 'dispatch_conditions'=>{}, 'unusual_conditions'=>{}}
      current_account.settings.auto_settings["auto_deliver"] = (params[:auto_deliver] == "on" ? 1 : nil )
      #current_account.settings.auto_settings["autocheck"] = params[:autocheck]
      current_account.settings.auto_settings["auto_dispatch"] = (params[:auto_dispatch] == "on" ? 1 : nil )
    when :user_init
      create_users(params[:cs], :cs)
      create_users(params[:stock_admin], :stock_admin)
      create_users(params[:interface], :interface)
    end
    current_account.settings[:wizard_step] = next_step_name
    render_wizard current_account
  end

  # invoke this action on front-end view by JavaScript
  def data_fetch_start
    if current_account && current_account.settings.init_data_ready.blank?
      current_account.settings.init_data_ready = false
      # do something like backend puller job.
    end
    head :ok
  end

  # invoke this action on front-end view by JavaScript
  def data_fetch_check
    result = current_account ? current_account.settings.init_data_ready == true : false
    render json: {ready: result}
  end

  # Please send a PUT request with account id as params[:id] to this action when
  # data fetch job finished in backend
  # eg: http://magicorder.networking.io/account_setups/:id/data_fetch_finish
  def data_fetch_finish
    account = Account.find_by_id(params[:id] )
    account.settings.init_data_ready = true if account
    head :ok
  end

  def edit_preprocess_settings
    @setting = current_account.settings.auto_settings || {}
    @setting['split_conditions'] = {} if !@setting['split_conditions'].present?
    @setting['unusual_conditions'] = {} if !@setting['unusual_conditions'].present?
  end

  def edit_dispatch_settings
    @setting = current_account.settings.auto_settings || {}
    @setting['dispatch_conditions'] = {} if !@setting['dispatch_conditions'].present?
  end

  def edit_deliver_settings
    @setting = current_account.settings.auto_settings || {}
  end


  def edit_automerge_settings
    @setting = current_account.settings.auto_settings || {}
  end
  def update_preprocess_settings
    @setting = decorate_auto_settings(params[:auto_settings])
    if @setting['preprocess_silent_gap'] != current_account.settings.auto_settings['preprocess_silent_gap']
      frequency_version = current_account.settings.auto_settings['unusual_conditions']['frequency_version']
      @setting['unusual_conditions']['frequency_version'] = (frequency_version == nil ? 1 : frequency_version + 1)
      current_settings = current_account.settings.auto_settings
      current_settings.update(@setting)
      current_account.settings.auto_settings = current_settings
      @setting = current_account.settings.auto_settings || {}
      UnusualStateMarker.new.perform(current_account.id, current_account.settings.auto_settings['unusual_conditions']['frequency_version'])
    else
      current_settings = current_account.settings.auto_settings
      current_settings.update(@setting)
      current_account.settings.auto_settings = current_settings
      @setting = current_account.settings.auto_settings || {}
    end
    redirect_to :back
  end

  def update_dispatch_settings
    @setting = decorate_auto_settings(params[:auto_settings])
    current_settings = current_account.settings.auto_settings
    current_settings.update(@setting)
    current_account.settings.auto_settings = current_settings
    @setting = current_account.settings.auto_settings || {}
    redirect_to :back
  end

  def update_deliver_settings
    @setting = decorate_auto_settings(params[:auto_settings])
    current_settings = current_account.settings.auto_settings
    current_settings.update(@setting)
    current_account.settings.auto_settings = current_settings
    @setting = current_account.settings.auto_settings || {}
    redirect_to :back
  end

  def update_automerge_settings
    @setting = decorate_auto_settings(params[:auto_settings])
    current_settings = current_account.settings.auto_settings
    current_settings.update(@setting)
    current_account.settings.auto_settings = current_settings
    @setting = current_account.settings.auto_settings || {}
    redirect_to :back, :notice=>"保存成功"
  end

  private
  def create_users(params, role)
    return if params.blank?
    params.split(',').each do |item|
      next unless item.match(User::EMAIL_FORMAT) && item.match(User::EMAIL_FORMAT)
      user = User.new(password: SecureRandom.hex(3))
      if item.match(User::EMAIL_FORMAT)
        user.email = item
      elsif item.match(User::PHONE_FORMAT)
        user.phone = item
      end
      user.save
      user.add_role(role)

      InitUserNotifier.perform_async(current_account.id, @user.email, @user.password, @user.phone)

    end
  end

  def decorate_auto_settings(hash)
    hash.each do |key, value|
      if value.is_a?(Hash)
        value.each do |sub_key, sub_value|
          hash[key][sub_key] = 1 if sub_value == "on"
          hash[key][sub_key] = nil if sub_value == "off"
        end
      else
        hash[key] = 1 if value == "on"
        hash[key] = nil if value == "off"
      end
    end

    hash
  end
end
