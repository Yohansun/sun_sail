class AlipayTradeOrder < ActiveRecord::Base

  attr_accessible :alipay_trade_history_id, :original_trade_sn, :trade_sn, :traded_at

  def get_alipay_revenues
    
  end

end
