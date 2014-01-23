# -*- encoding:utf-8 -*-
class AccountSetupsController < ApplicationController
  include Wicked::Wizard
  include MagicAutoSettings::ModelHelper
  include MagicAutoSettings::ViewHelper
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
      @user = User.new(params[:user].merge({is_admin: true}))
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
      @cs = init_role_user(params[:cs])
      is_cs_invalid = (@cs.is_a?(User) && @cs.invalid?)
      @stock_admin = init_role_user(params[:stock_admin])
      is_stock_invalid = (@stock_admin.is_a?(User) && @stock_admin.invalid?)

      if is_cs_invalid || is_stock_invalid
        render("user_init") and return
      else
        save_role_user(@cs, :cs) if @cs.is_a?(User)
        save_role_user(@stock_admin, :stock_admin) if @stock_admin.is_a?(User)
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
      @setting = AutoSetting.new(check_auto_settings(current_account.settings.auto_settings || {}))
    end

    define_method "update_#{block}_settings" do
      @settings = change_auto_settings(current_account, params[:auto_settings])
      redirect_to :back, :notice=>"保存成功。"
    end
  end

  private
  def init_role_user(params_user)
    return nil if params_user.select{|k, v| v.present?}.blank?
    User.new(params_user.merge({password: SecureRandom.hex(3)}))
  end

  def save_role_user(user, role)
    if user.save
      user.add_role(role)
      InitUserNotifier.perform_async(current_account.id, user.email, user.password, user.phone)
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
