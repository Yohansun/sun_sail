#encoding: utf-8
class Customer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,       type: String #顾客昵称
  field :email,      type: String #Email
  field :alipay_no,  type: String #买家支付宝账号
  field :buyer_area, type: String #顾客下单的地区
  field :account_id, type: Integer
  
  embeds_many :transaction_histories, :order => :created.desc
  validates :name,:presence => true, :uniqueness => {:scope => :account_id}
  
  accepts_nested_attributes_for :transaction_histories, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  validates_associated :transaction_histories

  USE_DAYS = [
    ["1-7天","1-7"],
    ["7-15天","7-15"],
    ["15-30天","15-30"]
  ]
  
  EXACT_PHRASE = [
    ["顾客ID","search[name_eq]"],
    ["联系电话","search[transaction_histories_receiver_mobile_eq]"],
    ["顾客邮箱","search[email_eq]"],
    ["顾客地址","search[transaction_histories_receiver_address_like]"]
  ]
  
  #潜在顾客->筛选所有未付款的订单
  scope :potential, where("transaction_histories.status" => {"$in" => ["TRADE_NO_CREATE_PAY","WAIT_BUYER_PAY","TRADE_CLOSED","TRADE_CLOSED_BY_TAOBAO"]})
  #购买顾客->筛选所有已付款的订单
  scope :paid     , where("transaction_histories.status" => {"$in" => ["TRADE_FINISHED"]})
  
  delegate :receiver_name,:receiver_mobile ,:receiver_state ,:receiver_city ,:receiver_district ,:receiver_address ,:to => :the_first,:allow_nil => true
  
  def the_first
    transaction_histories.desc(:created).first
  end

  def orders_price
    transaction_histories.sum(:payment)
  end

  def turnover
    transaction_histories.where(:status => "TRADE_FINISHED").sum(:payment)
  end

  def product_trades
    transaction_histories.where(:product_ids => {"$ne" => []})
  end
end