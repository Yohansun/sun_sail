# encoding : utf-8 -*-
class YihaodianAppToken < ActiveRecord::Base
  belongs_to :account
  belongs_to :trade_source

  attr_protected []
end