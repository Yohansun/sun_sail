require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Yihaodian < OmniAuth::Strategies::OAuth2
      option :name, "yihaodian" # can't use ali names in oauth urls

      option :client_options, {
        :site           => "https://member.yhd.com/login/authorize.action",
        :authorize_url  => "/login/authorize.action",
        :token_url      => "/login/token.action",
        :raise_errors   => false
      }

      option :token_params, {
        :parse          => :json,
        :param_name     => "access_token"
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