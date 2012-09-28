# -*- encoding : utf-8 -*-

require 'omniauth/strategies/taobao'

Rails.application.config.middleware.use OmniAuth::Builder do
  # app name MagicOrders订单test
  provider :taobao, '21198239', '4299a8edd3cd979b6f8ae9500fcc1dd5'
end