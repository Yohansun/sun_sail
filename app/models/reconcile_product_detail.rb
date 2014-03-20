# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: reconcile_product_details
#
#  id                     :integer(4)      not null, primary key
#  name                   :string(255)
#  outer_id               :string(255)
#  reconcile_statement_id :integer(4)
#  initial_num            :integer(4)
#  subtraction            :integer(4)
#  total_num              :integer(4)
#  last_month_num         :float
#  product_id             :integer(4)
#  offline_return         :integer(4)
#  hidden_num             :integer(4)
#  seller_id              :integer(4)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  audit_num              :integer(4)      default(0)
#  audit_price            :integer(4)      default(0)
#

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
                  :audit_price,
                  :sell_price
  belongs_to :reconcile_statement
  scope :by_ids, lambda { |rs_ids| where(["reconcile_statement_id in (?)", rs_ids]) }

  def redefine_last_month_num
    self.hidden_num ? self.last_month_num.to_i - self.hidden_num : self.last_month_num.to_i
  end

  def calculate_fees
    self.total_num = self.initial_num + self.redefine_last_month_num - self.subtraction - self.offline_return
    self.sell_price = self.initial_num * audit_price
    self.audit_num = self.total_num < 0 ? 0 : self.total_num.to_i * self.audit_price.to_i
    self.save
  end
end
