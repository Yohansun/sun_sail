require "digest/md5"
require "yaml"
require "uri"
require "rest"

module YihaodianQuery

  SANDBOX = 'http://119.97.231.228:2001/app/api/rest/router?'
  PRODBOX = 'http://openapi.1mall.com/app/api/rest/router?'
  USER_AGENT = 'jingdong_fu/1.1'
  REQUEST_TIMEOUT = 10
  API_VERSION = 1.0
  SIGN_ALGORITHM = 'md5'
  OUTPUT_FORMAT = 'json'

  class << self
    def load(config_file)
      @settings = YAML.load_file(config_file)
      @settings = @settings[Rails.env] if defined? Rails.env
      apply_settings
    end

    def settings=(settings)
      @settings = settings
      apply_settings
    end

    def apply_settings
      @base_url = @settings['is_sandbox'] ? SANDBOX : PRODBOX
    end

    def switch_to(sandbox_or_prodbox)
      @base_url = sandbox_or_prodbox
    end

    def get(options = {})
    end

    def post(options = {}, conditions)
      if conditions.present?
        YihaodianQuery.settings = conditions
        @response = TaobaoFu::Rest.post(@base_url, generate_query_vars(sorted_params(options)))
        parse_result @response
      end
    end

    def update(options = {})
    end

    def delete(options = {})
    end

    def sorted_params(params = {})
      sys_params = {
        :appKey                 => @settings['app_key'],
        :sessionKey             => @settings['access_token'],
        :format                 => OUTPUT_FORMAT,
        :ver                    => API_VERSION,
        :timestamp              => Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }
      sys_params.merge(params)
    end

    def generate_query_vars(params)
      params[:sign] = generate_sign(params.sort_by { |k,v| k.to_s }.flatten.join)
      params
    end

    def generate_sign(param_string)
      Digest::MD5.hexdigest(@settings['secret_key'] + param_string + @settings['secret_key'])
    end

    def parse_result(data)
      Crack::JSON.parse(data)
    end
  end
end