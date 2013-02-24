class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    @logistics = current_account.logistics
  end

  def dashboard
  end
end