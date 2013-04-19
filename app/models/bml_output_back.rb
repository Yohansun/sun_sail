# -*- encoding:utf-8 -*-
class BmlOutputBack  
	include Mongoid::Document

  field :tid, type: String
  field :out_sid, type: String #运单号 
  field :delivered_at, type: String
  field :logistic_code, type: String
  field :logictic_name, type: String 
  field :custom_id, type: String
  field :bml_stock_id, type: String
  field :weight, type: Float
  
  embeds_many :bml_sku_with_nums
  embedded_in :stock_out_bill
end