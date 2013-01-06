# == Schema Information
#
# Table name: alipay_trade_histories
#
#  id                :integer(4)      not null, primary key
#  finance_trade_sn  :string(255)
#  business_trade_sn :string(255)
#  merchant_trade_sn :string(255)
#  product_name      :string(255)
#  traded_at         :datetime
#  account_info      :string(255)
#  revenue_amount    :integer(10)
#  outlay_amount     :integer(10)
#  balance_amount    :integer(10)
#  trade_source      :string(255)
#  trade_type        :string(255)
#  memo              :string(500)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

class AlipayTradeHistory < ActiveRecord::Base
  # attr_accessible :title, :body
end
