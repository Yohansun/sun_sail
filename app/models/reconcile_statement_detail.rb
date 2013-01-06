# == Schema Information
#
# Table name: reconcile_statement_details
#
#  id                     :integer(4)      not null, primary key
#  reconcile_statement_id :integer(4)
#  alipay_revenue         :integer(4)
#  postfee_revenue        :integer(4)
#  trade_success_refund   :integer(4)
#  sell_refund            :integer(4)
#  base_service_fee       :integer(4)
#  store_service_award    :integer(4)
#  staff_award            :integer(4)
#  taobao_cost            :integer(4)
#  audit_cost             :integer(4)
#  collecting_postfee     :integer(4)
#  audit_amount           :integer(4)
#  adjust_amount          :integer(4)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

class ReconcileStatementDetail < ActiveRecord::Base
  # attr_accessible :title, :body
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :reconcile_statement, class_name: "ReconcileStatement"

  def self.to_xls_file(rs_ids)
  	ReconcileStatementDetail.where(["reconcile_statement_id in (?)", rs_ids])
  end
end
