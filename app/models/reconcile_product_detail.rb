class ReconcileProductDetail < ActiveRecord::Base
  attr_accessible :reconcile_statement_id,
                  :name,
                  :outer_id,
                  :initial_num,
                  :last_month_num,
                  :subtraction,
                  :total_num,
                  :product_id,
                  :offline_return,
                  :hidden_num,
                  :audit_num,
                  :audit_price
  belongs_to :reconcile_statement
  scope :by_ids, lambda { |rs_ids| where(["reconcile_statement_id in (?)", rs_ids]) }
  
  def redefine_last_month_num
    self.hidden_num ? self.last_month_num.to_i - self.hidden_num : self.last_month_num.to_i
  end

  def calculate_fees
    self.audit_num = self.total_num.to_i * self.audit_price.to_i
    self.save
  end
end