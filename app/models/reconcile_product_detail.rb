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
                  :hidden_num
  belongs_to :reconcile_statement
  scope :by_ids, lambda { |rs_ids| where(["reconcile_statement_id in (?)", rs_ids]) }
  
  def redefine_last_month_num
    self.last_month_num.to_i - self.hidden_num
  end
end