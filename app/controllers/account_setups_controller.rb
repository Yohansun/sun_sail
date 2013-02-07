class AccountSetupsController < ApplicationController
  include Wicked::Wizard

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
    when :data_fetch

    when :options_setup
      Account.current.write_setting('enable_auto_dispatch', params[:autodispatch].to_i)
      Account.current.write_setting('enable_auto_check', params[:autocheck].to_i)
      Account.current.write_setting('enable_auto_distribution', params[:autodistribution].to_i)
    when :user_init
      create_users(params[:cs], :cs)
      create_users(params[:stock], :stock_admin)
      create_users(params[:inter], :interface)
    end
    render_wizard Account.current
  end

  private
  def create_users(params, role)
    return if params.blank?
    params.split(',').each do |item|
      next unless item.match(User::EMAIL_FORMAT) && item.match(User::EMAIL_FORMAT)
      user = User.new
      if item.match(User::EMAIL_FORMAT)
        user.email = item
      elsif if item.match(User::PHONE_FORMAT)
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

end