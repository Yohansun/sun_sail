class StockProduct < ActiveRecord::Base
  attr_accessible :category, :descript, :iid, :name, :status, :taobao_id, :max, :safe_value

  validates_numericality_of :safe_value, :actual, :activity, less_than_or_equal_to: :max
  validates_numericality_of :safe_value, :actual, :activity, :max, greater_than_or_equal_to: 0
  validates_numericality_of :activity, less_than_or_equal_to: :actual

end
