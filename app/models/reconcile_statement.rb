# == Schema Information
#
# Table name: reconcile_statements
#
#  id                 :integer(4)      not null, primary key
#  trade_store_source :string(255)
#  trade_store_name   :string(255)
#  balance_amount     :float           default(0.0)
#  audited            :boolean(1)      default(FALSE)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  audit_time         :datetime
#  exported           :text
#  account_id         :integer(4)
#  seller_id          :integer(4)
#  processed          :boolean(1)      default(FALSE)
#

class ReconcileStatement < ActiveRecord::Base
  attr_accessible :trade_store_source, :trade_store_name, :audited, :trade_store_name, :audit_time, :balance_amount, :exported, :processed, :seller_id, :account_id
  include ActiveModel::ForbiddenAttributesProtection
  has_one :detail, class_name: "ReconcileStatementDetail"
  belongs_to :account
  scope :by_date, lambda { |date| where(["DATE_FORMAT(audit_time, '%Y%m') = ? ", date.sub(/-/,'')]) }

  scope :recently_data, order("audit_time DESC")

  validates :audit_time, uniqueness: true

  serialize :exported, Hash

  #结算状态的过程:未结算时 => 品牌商确认结算 => 运营商确认结算 => 已结算
  #audited false: 未结算,true: 运营商确认结算
  #processed: true:品牌已确认结算, false: 品牌未结算
  def self.all_audited?
    self.exists?(audited: false) ? false : true #audited = false 未结算,
  end

  def self.all_processed?
    self.exists?(processed: false) ? false : true
  end

end