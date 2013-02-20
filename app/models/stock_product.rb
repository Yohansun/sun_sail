# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: stock_products
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  max        :integer(4)      default(0)
#  safe_value :integer(4)      default(0)
#  activity   :integer(4)      default(0)
#  actual     :integer(4)      default(0)
#  product_id :integer(4)
#  seller_id  :integer(4)
#  sku_id     :integer(8)
#  num_iid    :integer(8)
#  account_id :integer(4)
#

class StockProduct < ActiveRecord::Base
  paginates_per 20

  belongs_to :account

  attr_accessible :max, :safe_value, :product_id, :seller_id, :color_ids, :actual, :activity, :sku_id, :num_iid

  validates_numericality_of :safe_value, :actual, :activity, less_than_or_equal_to: :max, message: '数量必须小于满仓值'
  validates_numericality_of :safe_value, :actual, :activity, :max, greater_than_or_equal_to: 0, message: '数量不能小于零'
  validates_numericality_of :activity, less_than_or_equal_to: :actual
  validates_presence_of :product_id, :seller_id, message: '必填项'
  validates_uniqueness_of :sku_id, scope: :seller_id
  belongs_to :product
  belongs_to :sku
  belongs_to :seller
  has_and_belongs_to_many :colors

  def sku_name
    sku_name = ''
    if sku.properties_name.present?
      properties = sku.properties_name.split(';')
      properties.each do |property|
        sku_values = property.split(':')
        sku_key =  sku_values[2]
        sku_value =  sku_values[3]
        sku_name = sku_name + sku_key + ':' + sku_value + '  '
      end
    end
    sku_name
  end

  def storage_status
    if activity < safe_value
      '预警'
    elsif actual == max
      '满仓'
    else
      '正常'
    end
  end

  def update_quantity!(num, opt_type)
    opt_activity = 0
    opt_actual = 0

    case opt_type
    when '入库'
      opt_activity = opt_actual = num
    when '出库'
      opt_activity = opt_actual = -num
    when '锁定'
      opt_activity = -num
    when '解锁'
      opt_activity = num
    when '发货'
      opt_actual = -num
    end

    update_attributes(activity: activity + opt_activity, actual: actual + opt_actual)
  end
end
