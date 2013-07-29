# -*- encoding : utf-8 -*-

require 'omniauth/strategies/taobao'
require 'omniauth/strategies/jingdong'

Rails.application.config.middleware.use OmniAuth::Builder do
  # app name MagicOrders订单test
  if ActiveRecord::Base.connection.tables.include?('settings') and !defined?(::Rake)
   # Mention this has no matter with account
    provider :taobao,TradeSetting.taobao_app_key, TradeSetting.taobao_app_secret
    provider :jingdong,TradeSetting.jingdong_app_key, TradeSetting.jingdong_app_secret
  end
end