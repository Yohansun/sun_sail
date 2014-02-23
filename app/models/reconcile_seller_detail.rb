class ReconcileSellerDetail < ActiveRecord::Base
  attr_accessible :reconcile_statement_id, 
                  :source,
                  :trade_source_name,
                  :alipay_revenue,
                  :postfee_revenue,
                  :base_fee,
                  :base_fee_rate,
                  :audit_amount,
                  :special_products_alipay_revenue,
                  :audit_amount_rate,
                  :special_products_alipay_revenue_rate,
                  :adjust_amount,
                  :last_audit_amount,
                  :user_id,
                  :buyer_payment,
                  :preferential,
                  :buyer_send_postage,
                  :taobao_deduction,
                  :credit_deduction,
                  :rebate_integral,
                  :actual_pey
  belongs_to :reconcile_statement

  scope :by_ids, lambda { |rs_ids| where(["reconcile_statement_id in (?)", rs_ids]) }

  def calculate_fees(base_fee_rate, audit_amount_rate, special_products_alipay_revenue_rate, adjust_amount)
    self.base_fee_rate = base_fee_rate
    self.audit_amount_rate = audit_amount_rate
    self.special_products_alipay_revenue_rate = special_products_alipay_revenue_rate
    self.adjust_amount = adjust_amount
    self.base_fee = (self.alipay_revenue - self.postfee_revenue) * self.base_fee_rate / 100
    self.audit_amount = (self.base_fee + self.postfee_revenue) * self.audit_amount_rate / 100 + self.special_products_alipay_revenue * self.special_products_alipay_revenue_rate / 100
    self.last_audit_amount = self.audit_amount + self.adjust_amount
    self.save
  end
  
end