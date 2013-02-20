class AccountSetupsController < ApplicationController
  include Wicked::Wizard
  before_filter :fetch_account, only: [:data_fetch_start, :data_fetch_check, :data_fetch_finish]

  steps :admin_init, :data_fetch, :options_setup, :user_init

  def index
    Account.current = Account.find_by_id(params[:account_id]) if params[:account_id]
    super
  end

  def show
    Rails.logger.debug "account setup ::: #{Account.current.inspect}"
    # case step
    # when :admin_init
    # when :data_fetch
    # when :options_setup
    # when :user_init
    # end
    render_wizard
  end

  def update
    case step
    when :admin_init
      user = User.new(params[:user])
      user.password = '123456'
      user.save
      user.add_role(:admin)
    when :options_setup
      Account.current.settings.enable_auto_dispatch = params[:autodispatch].to_i
      Account.current.settings.enable_auto_check = params[:autocheck].to_i
      Account.current.settings.enable_auto_distribution = params[:autodistribution].to_i
    when :user_init
      create_users(params[:cs], :cs)
      create_users(params[:stock], :stock_admin)
      create_users(params[:inter], :interface)
    end
    render_wizard Account.current
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
    @account.settings.init_data_ready = true if @account
    head :ok
  end

  private
  def create_users(params, role)
    return if params.blank?
    params.split(',').each do |item|
      next unless item.match(User::EMAIL_FORMAT) && item.match(User::EMAIL_FORMAT)
      user = User.new
      if item.match(User::EMAIL_FORMAT)
        user.email = item
      elsif item.match(User::PHONE_FORMAT)
        user.phone = item
      end
      user.password = '123456'
      # TODO: skip user validates??
      user.username = ''
      user.name = ''
      user.save(validate: false)
      user.add_role(role)
    end
  end

  def fetch_account
    @account = Account.find_by_id(params[:id]) if params[:id]
  end

end
