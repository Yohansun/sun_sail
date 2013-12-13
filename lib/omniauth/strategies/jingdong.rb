require 'omniauth-oauth2'
require 'omniauth/encode_handle'

module OmniAuth
  module Strategies
    class Jingdong < OmniAuth::Strategies::OAuth2
      option :name, "jidong"  # 京东不让用jingdong

      option :client_options, {
        :site           => "http://auth.360buy.com/oauth/authorize",
        :authorize_url  => "/oauth/authorize",
        :token_url      => "/oauth/token",
        :raise_errors   => false,
        :connection_build => lambda {|k|
          k.response :encode_handle
          k.request :url_encoded
          k.adapter Faraday.default_adapter
        }
      }

      option :token_params, {
        :parse          => :json
      }

      info do
        raw_info.merge(credentials)
      end

      def raw_info
        @raw_info ||= access_token.params
      end
    end
  end
end