# encoding: utf-8
# == Schema Information
#
# Table name: alipay_trade_orders
#
#  id                      :integer(4)      not null, primary key
#  reconcile_statement_id  :integer(4)
#  alipay_trade_history_id :integer(4)
#  original_trade_sn       :string(255)
#  trade_sn                :string(255)
#  traded_at               :datetime
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#

class AlipayTradeOrder < ActiveRecord::Base

  attr_accessible :reconcile_statement_id, :alipay_trade_history_id, :original_trade_sn, :trade_sn, :traded_at

  def get_alipay_revenues
    
  end

end
