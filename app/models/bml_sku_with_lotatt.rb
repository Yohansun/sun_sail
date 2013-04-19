# -*- encoding : utf-8 -*-
class BmlSkuWithLotatt
  include Mongoid::Document
  field :sku_code,                type: String
  field :received_time,           type: DateTime
            
  field :expected_qty, type: Integer #预期 数量 
  field :received_qty, type: Integer #实收数量  

  field :lotatt01,                  type: String
  field :lotatt02,                  type: String
  field :lotatt03,                  type: DateTime
  field :lotatt04,                  type: String
  field :lotatt05,                  type: String
  field :lotatt06,                  type: String
  field :lotatt07,                  type: String
  field :lotatt08,                  type: String
  field :lotatt09,                  type: String
  field :lotatt10,                  type: String
  field :lotatt11,                  type: String
  field :lotatt12,                  type: String

  embedded_in :bml_put_back

end