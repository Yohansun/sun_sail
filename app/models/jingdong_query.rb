# encoding : utf-8 -*-
require 'crack/json'
require 'oauth2'
module JingdongQuery

  def self.get(options = {}, conditions)
    if conditions.present?
      JingdongFu.settings = conditions
      JingdongFu.get(options)
    end
  end
end