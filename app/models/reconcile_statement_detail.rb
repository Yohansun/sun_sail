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
  attr_accessible :reconcile_statement_id, :alipay_revenue, :postfee_revenue, :trade_success_refund, :sell_refund, :base_service_fee, :store_service_award, :staff_award, :taobao_cost, :audit_cost, :collecting_postfee, :audit_amount, :adjust_amount
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :reconcile_statement

  scope :by_ids, lambda { |rs_ids| where(["reconcile_statement_id in (?)", rs_ids]) }

  def select_trades(page)
  	trade_tids = AlipayTradeOrder.where(reconcile_statement_id: self.reconcile_statement_id).map(&:trade_sn)
  	trades = Trade.in(tid: trade_tids).page(page)
  end
end