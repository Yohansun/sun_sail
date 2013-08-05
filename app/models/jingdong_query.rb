# encoding : utf-8 -*-
require 'crack/json'
require 'oauth2'
module JingdongQuery

  def self.get(options = {}, conditions)
    # trade_source = TradeSource.where(account_id: account_id, trade_type: "Jingdong").first
    # if trade_source
    #   #In development
    #   conditions = trade_source.attributes.update("access_token" => trade_source.jingdong_app_token.access_token)
    #   if Rails.env == "development" || Rails.env == "test"
    #     conditions = conditions.update("is_sandbox" => 'true')
    #   end
    if conditions.present?
      JingdongFu.settings = conditions
      JingdongFu.get(options)
    end
  end
end