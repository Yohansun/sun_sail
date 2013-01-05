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
#

class ReconcileStatement < ActiveRecord::Base
  # attr_accessible :title, :body
  include ActiveModel::ForbiddenAttributesProtection
  has_one :detail, class_name: "ReconcileStatementDetail"

end
