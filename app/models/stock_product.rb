# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: stock_products
#
#  id           :integer(4)      not null, primary key
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  max          :integer(4)      default(0)
#  safe_value   :integer(4)      default(0)
#  activity     :integer(4)      default(0)
#  actual       :integer(4)      default(0)
#  product_id   :integer(4)
#  seller_id    :integer(4)
#  sku_id       :integer(8)
#  num_iid      :integer(8)
#  account_id   :integer(4)
#  lock_version :integer(4)      default(0), not null
#

class StockProduct < ActiveRecord::Base
  # paginates_per 20

  belongs_to :account

  attr_accessible :max, :safe_value, :product_id, :seller_id, :color_ids, :actual, :activity, :sku_id, :num_iid, :account_id

  validates_numericality_of :safe_value, :actual, :activity, :max, greater_than_or_equal_to: 0, message: '数量不能小于零'
  validates_numericality_of :activity, less_than_or_equal_to: :actual
  validates_presence_of :product_id, :account_id, message: '必填项'
  belongs_to :product
  belongs_to :sku
  belongs_to :seller
  has_one :category , :through => :product,:source => :category
  has_and_belongs_to_many :colors
  scope :with_account, ->(account_id) { where(:account_id => account_id) }

  STORAGE_STATUS = {
    "预警" => "stock_products.activity < stock_products.safe_value",
    "满仓" => "stock_products.actual = stock_products.max",
    "正常" => "stock_products.activity >= stock_products.safe_value and stock_products.actual != stock_products.max"
  }

  def self.batch_update_activity_stock(relation,number)
    success = []
    fails = []
    relation.each do |record|
      record.update_activity_stock(number) ? success.push(record.id) : fails.push(record.id)
    end
    [success,fails]
  end

  def update_activity_stock(activity)
    transaction do
      self.activity = activity
      self.changes[:activity].tap do |ary|
        poor = ary.first - ary.last
        self.actual -= poor
        klass = poor > 0 ? StockOutBill : StockInBill
        return true if self.save! && create_stock_bill(klass,poor.abs)
      end if self.activity_changed?
    end rescue false
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

  private
  def create_stock_bill(klass,number)
    bill = klass.new(stock_typs: "VIRTUAL",:seller_id => self.seller_id ,account_id: self.account_id,bill_products_attributes: {"0" => {real_number: number, number: number,sku_id: self.sku_id}})
    bill.update_bill_products
    bill.save!
  end
end
