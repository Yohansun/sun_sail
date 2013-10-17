#encoding: utf-8
class PagesController < ApplicationController
  layout "management"
  before_filter :authorize
  before_filter :find_template
  include PagesHelper

  def index
    redirect_to action: :"#{@default_login_template}"
  end

  def default
    render template: "home/dashboard",layout: "application"
  end

  def overview
    refresh_pages_content if pages_cache_empty
    @undispatched_trades, @undelivered_trades, @delivered_trades, @unusual_trades = recent_trades
    render layout: "application"
  end

  def show

  end

  def update
    @account_settings.default_login_page_setting = %w(default overview).include?(params[:templete]) ? params[:templete] : "default"
    flash[:notice] = "更新成功"
    redirect_to action: :show
  end

  def reload_trades_percent_analysis
    refresh_content("trades_percent_analysis", trades_percent_analysis_hash)
    render :nothing => true
  end

  def reload_customers_percent_analysis
    refresh_content("customers_percent_analysis", customers_percent_analysis_hash)
    render :nothing => true
  end

  private

  def find_template
    @account_settings = current_account.settings
    @default_login_template = @account_settings.default_login_page_setting ||= "default"
  end

  def refresh_content(title, info)
    Rails.cache.write(title, info, expires_in: 5.minutes)
  end

  def pages_cache_empty
    return true if pages_hash.keys.reject{|v| Rails.cache.read(v).blank?}.blank?
  end

  def refresh_pages_content
    pages_hash.each{|key, value| refresh_content(key, value)}
  end
end
