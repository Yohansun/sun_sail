# -*- encoding:utf-8 -*-
class AccountSetupsController < ApplicationController
  include Wicked::Wizard
  include MagicAutoSettings
  layout :set_action_layout
  before_filter :check_account_wizard_status, only:[:show]
  skip_before_filter :verify_authenticity_token, only: [:data_fetch_finish]
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
        current_account.settings.auto_settings = check_auto_settings()
        binding_account_account_to_admin
      else
        current_account.settings[:wizard_step] = next_step_name
      end
      sign_in @user # auto login after create admin user
    when :options_setup
      current_account.settings.auto_settings = check_auto_settings()
      current_account.settings.auto_settings["auto_deliver"] = (params[:auto_deliver] == "on" ? 1 : nil )
      #current_account.settings.auto_settings["autocheck"] = params[:autocheck]
      current_account.settings.auto_settings["auto_dispatch"] = (params[:auto_dispatch] == "on" ? 1 : nil )
    when :user_init
      @cs = create_role_user(params[:cs], :cs)
      @stock_admin = create_role_user(params[:stock_admin], :stock_admin)
      if @cs.is_a?(User) || @stock_admin.is_a?(User)
        render("user_init") and return
      else
        binding_account_account_to_admin
      end
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
    account = Account.find(params[:id])
    account.settings.init_data_ready = true if account
    head :ok
  end

  AutoSettingsHelper::AutoBlocks.each do |block|
    define_method "edit_#{block}_settings" do
      @setting = check_auto_settings(current_account.settings.auto_settings || {})
    end

    define_method "update_#{block}_settings" do
      @settings = change_auto_settings(current_account, params[:auto_settings])
      redirect_to :back, :notice=>"保存成功。"
    end
  end

  private
  def create_role_user(params_user, role)
    return nil if params_user.select{|k, v| v.present?}.blank?
    user = User.new(password: SecureRandom.hex(3), username: params_user[:username])
    if params_user[:contact].to_s.match(User::EMAIL_FORMAT)
      user.email = params_user[:contact]
    else
      user.phone = params_user[:contact]
    end
    if user.save
      user.add_role(role)
      InitUserNotifier.perform_async(current_account.id, user.email, user.password, user.phone)
      nil
    else
      user
    end
  end

  def binding_account_account_to_admin
    admin_user = User.find_by_username("admin")
    if admin_user.present? && !admin_user.accounts.include?(current_account)
      admin_user.accounts << current_account
      admin_user.save
    end
  end

  def set_action_layout
    if ["show", "update"].include?(params[:action])
      "user_initialize"
    else
      "management"
    end
  end
end
