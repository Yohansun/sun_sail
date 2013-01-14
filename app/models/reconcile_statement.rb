# == Schema Information
#
# Table name: reconcile_statements
#
#  id                 :integer(4)      not null, primary key
#  trade_store_source :string(255)
#  trade_store_name   :string(255)
#  balance_amount     :integer(4)
#  audited            :boolean(1)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  audit_time         :datetime
#

class ReconcileStatement < ActiveRecord::Base
  attr_accessible :trade_store_source, :trade_store_name, :audited, :trade_store_name, :audit_time, :balance_amount, :exported
  include ActiveModel::ForbiddenAttributesProtection
  has_one :detail, class_name: "ReconcileStatementDetail"

  scope :by_date, lambda { |date| where(["DATE_FORMAT(audit_time, '%Y%m') = ? ", date.sub(/-/,'')]) }

  scope :recently_data, order("audit_time DESC")

  validates :audit_time, uniqueness: true

  serialize :exported, Hash
end
