# -*- encoding : utf-8 -*-

require 'omniauth/strategies/taobao'
require 'omniauth/strategies/jingdong'
require 'omniauth/strategies/yihaodian'

Rails.application.config.middleware.use OmniAuth::Builder do
  # app name MagicOrders订单test
  if ActiveRecord::Base.connection.tables.include?('settings') and !defined?(::Rake)
   # Mention this has no matter with account
    provider :taobao,TradeSetting.taobao_app_key, TradeSetting.taobao_app_secret, {:provider_ignores_state => true}
    provider :jingdong,TradeSetting.jingdong_app_key, TradeSetting.jingdong_app_secret, {:provider_ignores_state => true}
    provider :yihaodian,TradeSetting.yihaodian_app_key, TradeSetting.yihaodian_app_secret, {:provider_ignores_state => true}
  end
end