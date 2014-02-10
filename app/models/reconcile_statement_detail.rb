# == Schema Information
#
# Table name: reconcile_statement_details
#
#  id                     :integer(4)      not null, primary key
#  reconcile_statement_id :integer(4)
#  alipay_revenue         :integer(4)      default(0)
#  postfee_revenue        :integer(4)      default(0)
#  trade_success_refund   :integer(4)      default(0)
#  sell_refund            :integer(4)      default(0)
#  base_service_fee       :integer(4)      default(0)
#  store_service_award    :integer(4)      default(0)
#  staff_award            :integer(4)      default(0)
#  taobao_cost            :integer(4)      default(0)
#  audit_cost             :integer(4)      default(0)
#  collecting_postfee     :integer(4)      default(0)
#  audit_amount           :integer(4)      default(0)
#  adjust_amount          :integer(4)      default(0)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

class ReconcileStatementDetail < ActiveRecord::Base
  attr_protected []
  belongs_to :reconcile_statement

  validates :reconcile_statement_id, uniqueness: true

  scope :by_ids, lambda { |rs_ids| where(["reconcile_statement_id in (?)", rs_ids]) }

  def select_trades(page = "default")
  	trade_tids = AlipayTradeOrder.where(reconcile_statement_id: self.reconcile_statement_id).map(&:trade_sn)
  	page == "default" ? trades = Trade.in(tid: trade_tids) : trades = Trade.in(tid: trade_tids).page(page)
  	trades
  end

  def calculate_fees
    #基准价=（支付宝收入-运费）*自定义比例
    self.base_fee = (self.alipay_revenue - self.postfee_revenue) * self.base_fee_percent / 100
    #特供商品结算金额=特供商品支付宝收入*自定义比例
    self.special_products_audit_amount = self.special_products_alipay_revenue * self.special_products_audit_amount_percent / 100
    #结算金额=支付宝收入*自定义比例+特供商品结算金额+业绩
    self.audit_amount = self.alipay_revenue * self.audit_amount_percent / 100 + self.special_products_audit_amount + self.achievement
    #最终结算金额=结算金额+调整金额
    self.last_audit_amount = self.adjust_amount + self.audit_amount
    #账户提留=基准价*自定义比例+运费*自定义比例+特供商品支付宝收入*自定义比例
    self.account_profit = self.base_fee * self.account_profit_percent_a / 100 + self.postfee_revenue * self.account_profit_percent_b / 100 + self.special_products_alipay_revenue * self.account_profit_percent_c / 100
    #推广费预留=支付宝收入*自定义比例+特供商品支付宝收入*自定义比例
    self.advertise_reserved = self.alipay_revenue * self.advertise_reserved_percent_a / 100  + self.special_products_alipay_revenue * self.advertise_reserved_percent_b
    #平台扣点=支付宝收入*自定义比例+特供商品支付宝收入*自定义比例
    self.platform_deduction = self.alipay_revenue * self.platform_deduction_percent_a / 100 + self.special_products_alipay_revenue * self.platform_deduction_percent_b
    self.save

    rs = self.reconcile_statement
    rs.balance_amount = self.audit_amount
    rs.save
  end
  
end
