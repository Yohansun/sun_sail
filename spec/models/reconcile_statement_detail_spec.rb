require 'spec_helper'

describe ReconcileStatementDetail do
	it "use tids in alipay_orders to select trades " do
    rs = create(:reconcile_statement)
    rsd = create(:reconcile_statement_detail, reconcile_statement: rs)
    page = 1
    5.times{|i| create(:alipay_trade_order, reconcile_statement_id: rsd.reconcile_statement_id, trade_sn: i)}
    10.times{|i| create(:trade, tid: i)}

    trades = rsd.select_trades(page)
    trades.should_not be_empty
    trades.count.should == 5
  end
end
