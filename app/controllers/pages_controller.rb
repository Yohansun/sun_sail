#encoding: utf-8
class PagesController < ApplicationController
  layout "management"
  before_filter :authorize
  before_filter :find_template

  def index
    redirect_to action: :"#{@default_login_template}"
  end
  
  def default
    render template: "home/dashboard",layout: "application"
  end

  def overview
    #...
    render layout: "application"
  end

  def show
    
  end

  def update
    @account_settings.default_login_page_setting = %w(default overview).include?(params[:templete]) ? params[:templete] : "default"
    flash[:notice] = "更新成功"
    redirect_to action: :show
  end

  private
  def find_template
    @account_settings = current_account.settings
    @default_login_template = @account_settings.default_login_page_setting ||= "default"
  end
end
