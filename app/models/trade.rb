class Trade
  include Mongoid::Document

  field :seller_id, type: Integer
  field :dispatched_at, type: DateTime
  field :delivered_at, type: DateTime
end