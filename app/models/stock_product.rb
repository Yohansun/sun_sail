# -*- encoding : utf-8 -*-
class StockProduct < ActiveRecord::Base
  paginates_per 20

  attr_accessible :max, :safe_value, :product_id, :seller_id

  validates_numericality_of :safe_value, :actual, :activity, less_than_or_equal_to: :max, message: '数量必须小于满仓值'
  validates_numericality_of :safe_value, :actual, :activity, :max, greater_than_or_equal_to: 0, message: '数量不能小于零'
  validates_numericality_of :activity, less_than_or_equal_to: :actual
  validates_presence_of :product_id, :seller_id, message: '必填项'

  belongs_to :product
  belongs_to :seller

  def storage_status
  	if activity < safe_value
  		'预警'
  	elsif actual == max
  		'满仓'
  	else
  		'正常'
  	end
  end
end
