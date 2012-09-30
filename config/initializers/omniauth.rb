# -*- encoding : utf-8 -*-

require 'omniauth/strategies/taobao'

Rails.application.config.middleware.use OmniAuth::Builder do
  # app name MagicOrders订单test
  provider :taobao, TradeSetting.taobao_app_key, TradeSetting.taobao_app_secret
end