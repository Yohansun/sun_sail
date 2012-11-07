class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
  	@logistics = Logistic.all
  end

  def dashboard
  end
end