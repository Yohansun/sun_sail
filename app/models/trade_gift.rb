# -*- encoding : utf-8 -*-

class TradeGift
  include Mongoid::Document
  include Mongoid::Timestamps

  field :gift_tid,         type: String
  field :trade_id,         type: String
  field :gift_title,       type: String
  field :product_id,       type: Integer
  field :delivered_at,     type: DateTime

  embedded_in :trades
end