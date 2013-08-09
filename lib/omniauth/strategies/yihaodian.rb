require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Yihaodian < OmniAuth::Strategies::OAuth2
      option :name, "yihaodian" # can't use ali names in oauth urls

      option :client_options, {
        :site           => "http://fuwu.1mall.com/login/authorize.action",
        :authorize_url  => "/login/authorize.action",
        :token_url      => "/login/token.action",
        :raise_errors   => false
      }

      option :token_params, {
        :parse          => :json,
        :param_name     => "access_token"
      }

      extra do
        {
          :raw_info => raw_info
        }
      end

      info do
        {
          :access_token     => raw_info["accessToken"],
          :isv_id           => raw_info['isvId'],
          :merchant_id      => raw_info['merchantId'],
          :nick_name        => raw_info['nickName'],
          :user_code        => raw_info['userCode'],
          :user_id          => raw_info['userId'],
          :user_type        => raw_info['userType']
        }
      end

      def raw_info
        @raw_info ||= access_token.params
      end

    end
  end
end