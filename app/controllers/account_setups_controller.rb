class AccountSetupsController < ApplicationController
  include Wicked::Wizard
  before_filter :fetch_account, except: [:data_fetch_finish]

  skip_before_filter :verify_authenticity_token, only: [:data_fetch_finish]
  
  steps :admin_init, :data_fetch, :options_setup, :user_init

  def show
    Rails.logger.debug "account setup ::: #{@account.inspect}"
    render_wizard
  end

  def update
    case step
    when :admin_init       
      user = User.new(params[:user])
      user.password = SecureRandom.hex(3)
      user.save
      user.add_role(:admin)
      Notifier.init_user_notifications(user.email, user.password, @account.id).deliver if user.email.present?
      if user.phone.present?
        # USE SYSTEM SMS INTERFACE.
      end 
    when :options_setup
      # auto_settings should be init as a hash.
      @account.settings.auto_settings["autodispatch"] = params[:autodispatch]
      @account.settings.auto_settings["autocheck"] = params[:autocheck]
      @account.settings.auto_settings["autodistribution"] = params[:autodistribution]
    when :user_init
      create_users(params[:cs], :cs)
      create_users(params[:stock_admin], :stock_admin)
      create_users(params[:interface], :interface)
    end
    render_wizard @account
  end

  # invoke this action on fron-end view by JavaScript
  def data_fetch_start
    if @account && @account.settings.init_data_ready.blank?
      @account.settings.init_data_ready = false
      # do something like backend puller job.
    end
    head :ok
  end

  # invoke this action on front-end view by JavaScript
  def data_fetch_check
    result = @account ? @account.settings.init_data_ready == true : false
    render json: {ready: result }
  end

  # Please send a PUT request with account id as params[:id] to this action when
  # data fetch job finished in backend
  # eg: http://magicorder.networking.io/account_setups/:id/data_fetch_finish
  def data_fetch_finish
    account = Account.find_by_id(params[:id] )
    account.settings.init_data_ready = true if account
    head :ok
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
      Notifier.init_user_notifications(user.email, user.password, @account.id).deliver if user.email.present?
      if user.phone.present?
        # USE SYSTEM SMS INTERFACE.
      end 
    end
  end

  def fetch_account
    @account = Account.find_by_id(session[:account_id] ) if session[:account_id] 
  end

end
