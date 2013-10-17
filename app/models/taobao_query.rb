# encoding : utf-8 -*-
require 'crack/json'
require 'oauth2'
module TaobaoQuery

  def self.get(options = {}, trade_source_id = nil)
    source = TradeSource.find(trade_source_id)
    account = Account.find_by_id(source.account_id)
    if account
      if account.settings.taobao_auth_method == "TOP"
        TaobaoFu.select_source(trade_source_id)
        TaobaoFu.get(options)
      else
        oauth_https_get(options, trade_source_id)
      end
    end
  end

  def self.oauth_https_get(options, trade_source_id)
    #source_name用来选择订单源，代替之前的Taobaofu.select_source
    source = TradeSource.find(trade_source_id)
    if source && source.taobao_app_token
      token = source.taobao_app_token

      # Dulux set need_refresh to false
      token.check_or_refresh! if token.need_refresh

      base_url = 'https://eco.taobao.com/router/rest?'
      #sorted_params
      sorted_params = {
        access_token: token.access_token,
        format:      'json',
        v:           '2.0',
        timestamp:   Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }.merge!(options)
      #generate_query_string
      params_array = sorted_params.sort_by { |k,v| k.to_s }
      total_param = params_array.map { |key, value| key.to_s+"="+value.to_s }
      generate_query_string = URI.escape(total_param.join("&"))
      data = HTTParty.get(base_url + generate_query_string).parsed_response.to_json #Hash2JSON
      response = Crack::JSON.parse(data)
    end
  end

  def self.oauth_http_get(options, trade_source_id)
    #source_name用来选择订单源，代替之前的Taobaofu.select_source
    source = TradeSource.find(trade_source_id)
    if source && source.taobao_app_token
      token = source.taobao_app_token

      # Dulux set need_refresh to false
      token.check_or_refresh! if token.need_refresh

      base_url = 'http://gw.api.taobao.com/router/rest?'
      #sorted_params
      sorted_params = {
        session: token.access_token,
        format:      'json',
        v:           '2.0',
        app_key:      TradeSetting.taobao_app_key,
        sign_method: 'md5',
        timestamp:   Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }.merge!(options)
      #generate_query_string
      params_array = sorted_params.sort_by { |k,v| k.to_s }
      sign_token = Digest::MD5.hexdigest(TradeSetting.taobao_app_secret + params_array.flatten.join + TradeSetting.taobao_app_secret).upcase
      total_param = params_array.map { |key, value| key.to_s+"="+value.to_s }
      total_param = total_param + ["sign=#{sign_token}"]
      generate_query_string = URI.escape(total_param.join("&"))
      data = HTTParty.get(base_url + generate_query_string).parsed_response.to_json #Hash2JSON
      response = Crack::JSON.parse(data)
    end
  end

end