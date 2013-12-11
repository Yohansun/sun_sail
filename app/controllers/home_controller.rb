class HomeController < ApplicationController

  before_filter :check_account_wizard_status

  def index
  end

  def dashboard
  end
end