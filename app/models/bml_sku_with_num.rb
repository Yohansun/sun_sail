# -*- encoding : utf-8 -*-
class BmlSkuWithNum
  include Mongoid::Document
  field :sku,  type: String
  field :num,  type: Integer
  embedded_in :bml_output_back
end