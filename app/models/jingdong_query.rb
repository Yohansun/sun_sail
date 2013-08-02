# encoding : utf-8 -*-
require 'crack/json'
require 'oauth2'
module JingdongQuery

  def self.get(options = {}, account_id = nil)
    trade_source = TradeSource.where(account_id: account_id, trade_type: "Jingdong").first
    if trade_source
      #In development
      attributes = trade_source.attributes.update("access_token" => trade_source.jingdong_app_token.access_token)
      if Rails.env == "development" || Rails.env == "test"
        attributes = attributes.update("is_sandbox" => 'true')
      end
      JingdongFu.settings = attributes
      JingdongFu.get(options)
    end
  end
end