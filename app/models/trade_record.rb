# encoding: utf-8

class TradeRecord
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps
  include MagicEnum
  field :alipay_order_no, type: String  
  field :merchant_order_no, type: String 
  field :order_type, type: String  
  field :owner_user_id, type: String  
  field :owner_logon_id, type: String  
  field :owner_name, type: String  
  field :order_status, type: String  
  field :opposite_user_id, type: String  
  field :opposite_name, type: String  
  field :opposite_logon_id, type: String  
  field :order_title, type: String  
  field :total_amount, type: Float   
  field :service_charge, type: Float   
  field :order_from, type: String
  field :create_time, type: DateTime 
  field :modified_time, type: DateTime 
  field :in_out_type, type: String
  field :trade_source_id, type: Integer
  field :account_id, type: Integer

  def get_surplus
    in_out_type == "in" ? total_amount - service_charge : -(total_amount + service_charge) 
  end
 
end