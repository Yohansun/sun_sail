# -*- encoding : utf-8 -*-
class TaobaoTradeRate < ActiveRecord::Base
  validates_uniqueness_of :oid
  attr_accessible  :tid, :oid, :content, :created, :item_price, :item_title, :nick, :rated_nick, :result, :role, :reply
end
