# -*- encoding:utf-8 -*-
class BmlInputBack  
	include Mongoid::Document

  field :warehouseid,               type: String #仓库编号 
  field :asnno,                     type: String #仓内入库流水号 
  field :custmor_order_no,          type: String #客户采购单号 
  field :expected_arrive_time,      type: DateTime #预期到货日期 
 
  embedded_in :stock_in_bill
  embeds_many :bml_sku_with_lotatts
end