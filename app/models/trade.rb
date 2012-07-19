class Trade
  include Mongoid::Document

  field :seller_id, type: Integer
end