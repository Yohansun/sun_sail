# -*- encoding : utf-8 -*-

class TradeGift
  include Mongoid::Document
  include Mongoid::Timestamps

  field :gift_tid,         type: String
  field :trade_id,         type: String
  field :gift_title,       type: String
  field :num_iid,          type: Integer
  field :sku_id,           type: Integer
  field :num,              type: Integer
  field :delivered_at,     type: DateTime

  validates_uniqueness_of :gift_tid

  embedded_in :trades
end