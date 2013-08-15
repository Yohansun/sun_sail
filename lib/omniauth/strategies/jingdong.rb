require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Jingdong < OmniAuth::Strategies::OAuth2
      option :name, "jingdong"

      option :client_options, {
        :site           => "http://auth.360buy.com/oauth/authorize",
        :authorize_url  => "/oauth/authorize",
        :token_url      => "/oauth/token"
      }

      option :token_params, {
        :parse          => :json
      }

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