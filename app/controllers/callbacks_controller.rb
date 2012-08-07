require "open-uri"

class CallbacksController < ApplicationController
  def jingdong
    code = params[:code]

    config_file = File.join(Rails.root, "config", "jingdong.yml")
    settings = YAML.load_file(config_file)
    settings = settings[Rails.env] if defined? Rails.env

    access_url = "https://auth.360buy.com/oauth/token?grant_type=authorization_code&client_id=#{settings['app_key']}&
redirect_uri=#{CGI.escape("http://magicalpha.doorder.com/callbacks/jingdong")}&code=#{code}&state=hi&client_secret=#{settings['secret_key']}"

    access_url.gsub!("https", "http")

    uri = URI.parse(URI.encode(access_url))

    result = uri.read

    render text: result
  end
end