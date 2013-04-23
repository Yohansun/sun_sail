# -*- encoding:utf-8 -*-
class StockBill  
	include Mongoid::Document
 	embeds_many :bill_products

  field :tid, type: String
  field :customer_id, type: String
  field :op_state, type: String
  field :op_city, type: String
  field :op_district, type: String
  field :op_address, type: String 
  field :op_name, type: String
  field :op_mobile, type: String
  field :op_zip, type: String
  field :op_phone, type: String
  field :created_at, type: DateTime
  field :checked_at, type: DateTime
  field :stocked_at, type: DateTime 
  field :confirm_stocked_at, type: DateTime #标杆反馈,确认出库时间
  field :confirm_failed_at, type: DateTime #标杆反馈,系统操作失败时间
  field :canceled_at, type: DateTime  
  field :cancel_succeded_at, type: DateTime
  field :cancel_failed_at, type: DateTime
  field :failed_desc, type: String
  field :sync_at, type: DateTime
  field :sync_succeded_at, type: DateTime
  field :sync_failed_at, type: DateTime     
  field :logistic_code, type: Integer  
  field :stock_id, type: Integer
  field :stock_type, type: String
  field :remark, type: String 
  field :account_id, type: Integer

  field :bill_products_mumber, type: Integer
  field :bill_products_price, type: Float

  field :operator_id, type: Integer
  field :operator_name, type: String
  
  embeds_many :bill_products
  
  after_save :generate_tid

  def generate_tid
    if tid.blank?
      serial = Time.now.to_s(:number)
      salt = SecureRandom.hex(10).upcase[0, 3]
      serial_num = serial + salt
      update_attributes!(tid: serial_num) 
    end  
  end

  def status
    if checked_at
      "已审核"
    else
      "未审核"
    end  
  end 

end