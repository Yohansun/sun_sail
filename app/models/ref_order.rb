class RefOrder
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :sku_id, type: String
  field :num, type: Integer

  embedded_in :ref_batches
end