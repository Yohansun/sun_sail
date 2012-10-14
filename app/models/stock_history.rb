# -*- encoding : utf-8 -*-
class StockHistory < ActiveRecord::Base
	paginates_per 20

  attr_accessible :number, :operation, :stock_product_id, :tid, :reason, :note, :seller_id
  belongs_to :stock_product
  belongs_to :user
  belongs_to :seller

  validates_presence_of :stock_product_id, :number, :operation, :seller_id


  def reason_string
  	case reason
  	when 'i1'
  		'生产入库'
  	when 'i0'
  		'其他原因'
  	when 'o0'
  		'其他原因'
  	when 'o1'
  		'销售出库'
  	else
  		''
  	end
  end
end
