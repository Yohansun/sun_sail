require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Taobao < OmniAuth::Strategies::OAuth2
      option :name, "taodan" # can't use ali names in oauth urls

      option :client_options, {
        :site           => "https://oauth.taobao.com/authorize",
        :authorize_url  => "/authorize",
        :token_url      => "/token"
      }

      option :token_params, {
        :parse          => :json
      }

      info do
        {
          :taobao_user_id     => raw_info['taobao_user_id'],
          :taobao_user_nick   => raw_info['taobao_user_nick']
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.params
      end
    end
  end
end