# -*- encoding : utf-8 -*-

require 'omniauth/strategies/taobao'

Rails.application.config.middleware.use OmniAuth::Builder do
  # app name MagicOrders订单test
  if ActiveRecord::Base.connection.tables.include?('settings') and !defined?(::Rake)
    provider :taobao, TradeSetting.taobao_app_key, TradeSetting.taobao_app_secret
  end
end